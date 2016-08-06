package App::DarkPAN::Command::inspect;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use Parse::CPAN::Packages ();
use Parse::CPAN::Authors  ();

use App::DarkPAN -command;

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'packages',   'inspect packages' ],
        [ 'authors',    'inspect authors' ],
        [],
        $class->SUPER::opt_spec,
    )
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $root = Path::Tiny::path( $opt->root );

    die "Not a DarkPAN repository: $root"
        unless -d $root->child('CPAN')
            && -d $root->child('QUAR')
            && -d $root->child('INBX');

    my $cpan     = $root->child('CPAN');
    my $authors  = $cpan->child('authors/01mailrc.txt.gz');
    my $packages = $cpan->child('modules/02packages.details.txt.gz');

    if ( $opt->authors ) {
        my $pca = Parse::CPAN::Authors->new( $authors->stringify );

        if ( my @authors = $pca->authors ) {
            printf "Found %d authors.\n", scalar @authors;
            foreach my $author ( sort { $a->pauseid cmp $b->pauseid } @authors ) {
                printf "%s %s %s\n", $author->pauseid, $author->email, $author->name;
            }
        }
        else {
            print "No authors.\n"
        }
    }
    elsif ( $opt->packages ) {
        my $pcp = Parse::CPAN::Packages->new( $packages->stringify );

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

# ABSTRACT: Inspect a DarkPAN repository

=pod

=head1 NAME

App::DarkPAN::Command::inspect - Inspect a DarkPAN repository

=head1 DESCRIPTION

=cut
