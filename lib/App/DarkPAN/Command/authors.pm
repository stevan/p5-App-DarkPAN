package App::DarkPAN::Command::authors;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'pauseid=s', 'the pauseid to filter on' ],
        [ 'json=s',    'a JSON payload' ],
        [],
        [ 'select',    'select the author(s)' ],
        [ 'update',    'update the author' ],
        # [ 'delete',    'delete the author' ],
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

    my $model   = App::DarkPAN::Model->new( root => $root );
    my $authors = $model->authors;
    my $pauseid = $opt->pauseid;

    if ( $opt->select ) {

        if ( $pauseid ) {
            if ( my $author = $authors->get( $pauseid ) ) {
                $self->display_author( $author );
            }
            else {
                print "Unable to find author for ($pauseid)\n";
            }
        }
        else {
            if ( my @authors = $authors->get_all ) {
                printf "Found %d authors.\n", scalar @authors;
                $self->display_author( $_ ) foreach @authors;
            }
            else {
                print "No authors.\n"
            }
        }
    }
    elsif ( $opt->update ) {

        if ( $authors->has( $pauseid ) ) {
            print "Found author ($pauseid), updating ...\n";
        }
        else {
            print "Unable to find author for ($pauseid), creating ...\n";
        }

        my $data = $App::DarkPAN::Model::JSON->decode( $opt->json );
        $authors->set( $pauseid, $data );
        $authors->store;
    }

}

sub display_author {
    my ($self, $author) = @_;
    printf "%s \"%s <%s>\"\n", $author->{pauseid}, $author->{name}, $author->{email};
}

1;

__END__

# ABSTRACT: Perform operations on the Authors data

=pod

=head1 DESCRIPTION

=cut
