package App::DarkPAN::Command::repo::submit;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny         ();
use YAML               ();
use List::Util         qw[ first ];
use Archive::Tar       ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

sub command_names { 'repo/submit' }

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'file=s',   'file to submit to DarkPAN', { required => 1 } ],
        [ 'author=s', 'PAUSE author name',         { required => 1 } ],
        [],
        $class->SUPER::opt_spec,
    )
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $root = Path::Tiny::path( $opt->root );

    die "Not a DarkPAN repository: $root"
        unless -d $root->child('CPAN')
            && -d $root->child('DBOX');

    my $in_file = Path::Tiny::path( $opt->file );
    die 'Unable to find file ('.$opt->file.')' unless -e $in_file;

    my $meta = $self->load_metayaml( $in_file->stringify );
    die 'Unable to find meta file inside ('.$opt->file.')' unless $meta;
    
    my $author       = $opt->author;    
    my $dbox         = $root->child('DBOX');    
    my $modlist_file = $dbox->child('modlist.json');
    my $authors_dir  = $dbox->child('authors')
                            ->child('id')
                            ->child( substr $author, 0, 1 )
                            ->child( substr $author, 0, 2 )
                            ->child( $author );
    
    $authors_dir->mkpath unless -d $authors_dir;
    $modlist_file->touch unless -e $modlist_file;
    
    my $out_file = $in_file->copy( $authors_dir );
    
    my $JSON     = App::DarkPAN::Model->JSON;
    my $modlist  = -s $modlist_file ? $JSON->decode( $modlist_file->slurp ) : [];
    
    push @$modlist => {
        module   => $meta->{name} =~ s/-/::/gr,
        version  => $meta->{version},
        authorid => $opt->author,
        file     => $out_file->relative( $dbox )->stringify,
    };
    
    $modlist_file->spew( $JSON->encode( $modlist ) );
}

sub load_metayaml {
    my ($self, $file) = @_;

    my $tar = Archive::Tar->new;
    $tar->read( $file );

    my $meta_file = first { /META\.yml$/ } $tar->list_files;

    return unless $meta_file;
    return YAML::Load( $tar->get_content( $meta_file ) );
}

1;

__END__

# ABSTRACT: Submit module to a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
