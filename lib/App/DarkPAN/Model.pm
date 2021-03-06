package App::DarkPAN::Model;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny   ();
use Scalar::Util ();
use JSON::XS     ();

use App::DarkPAN::Model::Authors;
use App::DarkPAN::Model::Packages;

# ... some gloablly used stuff

our $JSON = JSON::XS->new->utf8->pretty->canonical;

# ...

sub new {
    my ($class, %args) = @_;

    $args{root} = Path::Tiny::path( $args{root} )
        unless Scalar::Util::blessed( $args{root} )
            && $args{root}->isa('Path::Tiny');

    return bless {
        root => $args{root},
    } => $class;
}

sub JSON { $JSON }

sub authors {
    my ($self) = @_;
    return App::DarkPAN::Model::Authors->new(
        file => $self->{root}->child('CPAN/authors/01mailrc.txt.gz')
    )
}

sub packages {
    my ($self) = @_;
    return App::DarkPAN::Model::Packages->new(
        file => $self->{root}->child('CPAN/modules/02packages.details.txt.gz')
    )
}

1;

__END__

# ABSTRACT: Interface to the data models

=pod

=head1 DESCRIPTION

=cut
