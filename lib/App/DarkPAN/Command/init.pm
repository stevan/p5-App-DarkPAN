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
    my $dbox = $root->child('DBOX');

    $cpan->mkpath;
    $dbox->mkpath;

    my $f = CPAN::Faker->new(
        source => $dbox->stringify,
        dest   => $cpan->stringify,
        # NOTE:
        # Adding in the URL here because it
        # was causing an warning occasionally
        # when creating this object because
        # the `url` field relies on the `dest`
        # field, and order initialization order
        # is undefined, so the `url` field should
        # be marked lazy, but since this is
        # just a temp thing, we can leave it
        # here as a hack/fix.
        # - SL
        url    => ('file://' . $cpan->stringify . '/'),
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
