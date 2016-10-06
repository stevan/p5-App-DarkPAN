package App::DarkPAN::Command::init;

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
    
    my $m = App::DarkPAN::Model->new( root => $root );
    
    # now create the empty files ...
    my $authors  = $m->authors;
    my $packages = $m->packages;

    print "DarkPAN created in ($root)\n";
}

1;

__END__

# ABSTRACT: Initialize a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
