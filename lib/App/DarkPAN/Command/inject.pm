package App::DarkPAN::Command::inject;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny         ();
use CPAN::Mini::Inject ();

use App::DarkPAN -command;

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'dry-run', 'List the staged modules, but do not inject them' ],
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

    my $mcpi = CPAN::Mini::Inject->new;
    $mcpi->parsecfg;

    if ( $opt->dry_run ) {
        $mcpi->readlist;
        if ( my @modules = @{ $mcpi->{modulelist} } ) {
            printf "Found %d modules.\n", scalar @modules;
            foreach my $mod ( @modules ) {
                print $mod =~ s/\s+/ /gr, "\n";
            }
        }
        else {
            print "No modules.\n"
        }
    }
    else {
        $mcpi->inject;
    }
}

1;

__END__

# ABSTRACT: Inject modules into a DarkPAN repository

=pod

=head1 NAME

App::DarkPAN::Command::inject - Inject modules into a DarkPAN repository

=head1 DESCRIPTION

=cut
