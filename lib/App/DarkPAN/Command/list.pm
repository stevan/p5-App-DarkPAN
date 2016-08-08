package App::DarkPAN::Command::list;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use Parse::CPAN::Packages ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'packages',   'list packages' ],
        [ 'authors',    'list authors' ],
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

    my $cpan = $root->child('CPAN');

    if ( $opt->authors ) {

        my $m = App::DarkPAN::Model->new( root => $root );
        my $a = $m->authors;

        if ( my @authors = $a->get_all ) {
            printf "Found %d authors.\n", scalar @authors;
            foreach my $author ( sort { $a->{pauseid} cmp $b->{pauseid} } @authors ) {
                printf "%s \"%s <%s>\"\n", $author->{pauseid}, $author->{name}, $author->{email};
            }
        }
        else {
            print "No authors.\n"
        }
    }

    if ( $opt->packages ) {
        my $packages = $cpan->child('modules/02packages.details.txt.gz');
        my $pcp      = Parse::CPAN::Packages->new( $packages->stringify );

        if ( my @packages = $pcp->packages ) {
            printf "Found %d packages.\n", scalar @packages;
            foreach my $pkg ( sort { $a->package cmp $b->package } @packages ) {
                printf "%s %s %s\n", $pkg->package, $pkg->version, $pkg->distribution->prefix;
            }
        }
        else {
            print "No packages.\n"
        }
    }

}

1;

__END__

# ABSTRACT: List authors and packages in a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
