package App::DarkPAN::Command::repo_submit;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny         ();
use YAML               ();
use List::Util         qw[ first ];
use Archive::Tar       ();
use CPAN::Mini::Inject ();

use App::DarkPAN -command;

sub command_names { 'repo/submit' }

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'file=s',   'file to submit to DarkPAN' ],
        [ 'author=s', 'PAUSE author name' ],
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

    my $file = Path::Tiny::path( $opt->file );
    die 'Unable to find file ('.$opt->file.')' unless -e $file;

    my $meta = $self->load_metayaml( $file->stringify );
    die 'Unable to find meta file inside ('.$opt->file.')' unless $meta;

    my $module = $meta->{name} =~ s/-/::/gr; # /
    my $mcpi   = CPAN::Mini::Inject->new;
    $mcpi->parsecfg( $root->child('mcpani.config')->stringify );
    $mcpi->readlist;
    $mcpi->add(
        file     => $file->stringify,
        module   => $module,
        version  => $meta->{version},
        authorid => $opt->author,
    );
    $mcpi->writelist;
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
