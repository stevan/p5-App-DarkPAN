package App::DarkPAN::Command::repo::review;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

sub command_names { 'repo/review' }

sub opt_spec {
    my ($class) = @_;
    return (
        $class->SUPER::opt_spec,
    )
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $root = Path::Tiny::path( $opt->root );

    die "Not a DarkPAN repository: $root"
        unless -d $root->child('CPAN')
            && -d $root->child('DBOX');

    my $modlist = App::DarkPAN::Model->JSON->decode( 
        $root->child('DBOX')
             ->child('modlist.json')
             ->slurp 
    );

    if ( @$modlist ) {
        my $num_modules = scalar @$modlist;
        print "Found $num_modules module(s).\n";
        print $self->generate_data_table( $modlist ), "\n";
    }
    else {
        print "No modules.\n"
    }
}

1;

__END__

# ABSTRACT: Inject modules into a DarkPAN repository

=pod

=head1 DESCRIPTION

=cut
