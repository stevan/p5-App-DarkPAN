package App::DarkPAN::Command::select;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

# darkpan select --from authors --where name --matches 'John*'

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'from=s',    'the model to select from' ],
        [],
        [ 'where=s',   'the key to match on'      ],
        [ 'matches=s', 'the regexp to match with' ],
        [],
        [ 'extract=s', 'the key to extract (optional)' ],
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

    my $from    = $opt->from;
    my $where   = $opt->where;
    my $matches = $opt->matches;

    my $model = App::DarkPAN::Model->new( root => $root );
    
    die 'Cannot find model type:' . $from
        unless $model->can($from);

    my $m = $model->$from();
    if ( my @data = $m->select( $where, $matches ) ) {
        
        printf "Got %d results\n", scalar @data if $opt->verbose;
        warn Data::Dumper::Dumper( \@data )     if $opt->debug;
        
        if ( my $key = $opt->extract ) {
            print $_->{ $key }, "\n" foreach @data;   
        }
        else {
            print $m->pack_data_into_line( $_ ) foreach @data;    
        }
    }
    else {
        print "Unable to find author for ($matches)\n" if $opt->verbose;
    }
}

1;

__END__

# ABSTRACT: Perform operations to select data from models

=pod

=head1 DESCRIPTION

=cut