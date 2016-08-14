package App::DarkPAN::Command::packages;

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
        [ 'package=s', 'the package to filter on' ],
        [ 'json=s',    'a JSON payload' ],
        [],
        [ 'select',    'select the package(s)' ],
        [ 'update',    'update the package' ],
        # [ 'delete',    'delete the package' ],
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

    my $model    = App::DarkPAN::Model->new( root => $root );
    my $packages = $model->packages;
    my $package  = $opt->package;

    if ( $opt->select ) {

        if ( $package ) {
            if ( my $package = $packages->get( $package ) ) {
                $self->display_package( $package );
            }
            else {
                print "Unable to find entry for ($package)\n";
            }
        }
        else {
            if ( my @packages = $packages->get_all ) {
                printf "Found %d packages.\n", scalar @packages;
                $self->display_package( $_ ) foreach @packages;
            }
            else {
                print "No packages.\n"
            }
        }
    }
    elsif ( $opt->update ) {

        # TODO:
        # convert this into a
        # validate args thing and
        # maybe have it throw a
        # $self->usage_error instead
        # - SL
        die 'Cannot update without specifying a package' unless $package;

        if ( $packages->has( $package ) ) {
            print "Found package ($package), updating ...\n";
        }
        else {
            print "Unable to find entry for ($package), creating ...\n";
        }

        my $data = $App::DarkPAN::Model::JSON->decode( $opt->json );
        $packages->set( $package, $data );
        $packages->store;
    }

}

sub display_package {
    my ($self, $package) = @_;
    printf "%-32s %-5s %s\n", $package->{package}, $package->{version}, $package->{dist_filename};
}

1;

__END__

# ABSTRACT: Perform operations on the Authors data

=pod

=head1 DESCRIPTION

=cut
