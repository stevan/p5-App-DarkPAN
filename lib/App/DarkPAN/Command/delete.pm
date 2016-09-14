package App::DarkPAN::Command::delete;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::DarkPAN::Model;

use App::DarkPAN -command;

=pod

darkpan delete
    --from     authors    # look in authers
    --where    pauseid    # match against the pauseid field
    --matches  STEV[EA]N  # use this as a regexp to match against

=cut

sub command_names { 'data/delete' }

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'from=s',    'the model to delete the data from' => { required => 1 } ],
        [],
        [ 'where=s',   'the key to match on'               => { required => 1 } ],
        [ 'matches=s', 'the regexp to match with'          => { required => 1 } ],
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
    
    $m->delete( $where, $matches );
}

1;

__END__

# ABSTRACT: Perform operations to update data from models

=pod

=head1 DESCRIPTION

=cut
