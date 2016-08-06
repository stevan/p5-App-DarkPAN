package App::DarkPAN::Command::init;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny  ();
use CPAN::Faker ();

use App::DarkPAN -command;

sub opt_spec {
    my ($class) = @_;
    return (
        $class->SUPER::opt_spec,
    )
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $root = Path::Tiny::path( $opt->root );

    die "Cannot initialize DarkPAN repository unless directory ($root) is empty"
        unless 0 == scalar $root->children;

    my $cpan = $root->child('CPAN');
    my $quar = $root->child('QUAR');
    my $inbx = $root->child('INBX');

    $cpan->mkpath;
    $quar->mkpath;
    $inbx->mkpath;

    my $f = CPAN::Faker->new(
        source => $quar->stringify,
        dest   => $cpan->stringify,
    );

    $f->make_cpan;

    print "DarkPAN created in ($root)\n";
}

1;

__END__

# ABSTRACT: Initialize a DarkPAN repository

=pod

=head1 NAME

App::DarkPAN::Command::init - Initialize a DarkPAN repository

=head1 DESCRIPTION

=cut
