package App::DarkPAN::Command::data::update;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

=pod

darkpan data/update
    --into     authors    # look in authers
    --where    pauseid    # match against the pauseid field
    --matches  STEV[EA]N  # use this as a regexp to match against
    --data     '{"pauseid":"STEVAN", ...}'
    # or ...
    -- '{"pauseid":"STEVAN", ...}'
    # or ...
    < STEVAN.json
    
=cut

sub command_names { 'data/update' }

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'into=s',    'the model to update the data in' => { required => 1 } ],
        [],
        [ 'where=s',   'the key to match on'             => { required => 1 } ],
        [ 'matches=s', 'the regexp to match with'        => { required => 1 } ],
        [],
        [ 'data=s',    'a JSON string of the new data' ],
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

    my $into    = $opt->into;
    my $where   = $opt->where;
    my $matches = $opt->matches;
    my $json    = $opt->data;
    if ( not defined $json ) {
        if ( @$args && $args->[0] eq '--' ) {
            $json = join '' => @{$args}[ 1 .. $#{$args} ];
        }
        else {
            $json = join '' => <STDIN>;
        }    
    }
    
    die "You must supply data to update with using --data, -- or STDIN"
        unless $json;

    my $model = App::DarkPAN::Model->new( root => $root );
    
    die 'Cannot find model type:' . $into
        unless $model->can($into);

    my $JSON = $model->JSON;
    my $data = $JSON->decode( $json );

    my $m = $model->$into();
    
    $m->update( $data, $where, $matches );
}

1;

__END__

# ABSTRACT: Perform operations to update data from models

=pod

=head1 DESCRIPTION

=cut
