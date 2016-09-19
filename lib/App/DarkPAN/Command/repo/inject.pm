package App::DarkPAN::Command::repo::inject;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny         ();
use CPAN::Mini::Inject ();

use App::DarkPAN -command;

sub command_names { 'repo/inject' }

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
            && -d $root->child('DBOX');

    my $mcpi = CPAN::Mini::Inject->new;
    $mcpi->parsecfg( $root->child('mcpani.config') );
    $mcpi->readlist;

    my $num_modules;
    if ( my @modules = @{ $mcpi->{modulelist} } ) {
        $num_modules = scalar @modules;
        print "Found $num_modules modules.\n";
        foreach my $mod ( @modules ) {
            print $mod =~ s/\s+/ /gr, "\n";
        }
    }
    else {
        print "No modules.\n"
    }

    my $prefix = $opt->dry_run ? '[dry-run] ' : '';
    print "${prefix}Injecting $num_modules modules into DarkPAN.\n";
    unless ( $opt->dry_run ) {
        $mcpi->inject;
        print "$num_modules module(s) injected into the DarkPAN.\n";
    }
}

1;

__END__

# ABSTRACT: Inject modules into a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
