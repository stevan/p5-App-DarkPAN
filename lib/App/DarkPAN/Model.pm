package App::DarkPAN::Model;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny   ();
use Scalar::Util ();

use App::DarkPAN::Model::Authors;

sub new {
    my ($class, %args) = @_;

    $args{root} = Path::Tiny::path( $args{root} )
        unless Scalar::Util::blessed( $args{root} )
            && $args{root}->isa('Path::Tiny');

    return bless {
        root => $args{root},
    } => $class;
}

sub authors {
    my ($self) = @_;
    return App::DarkPAN::Model::Authors->load(
        $self->{root}->child('CPAN/authors/01mailrc.txt.gz')
    )
}

1;

__END__

# ABSTRACT: Interface to the data models

=pod

=head1 DESCRIPTION

=cut
