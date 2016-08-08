package App::DarkPAN::Model::Authors;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny   ();
use Scalar::Util ();
use IO::Zlib     ();

sub new; # use load

sub _new {
    my ($class, %args) = @_;

    return bless {
        file => $args{file},
        data => {},
    } => $class;
}

sub get_all {
    my $self = $_[0];
    return values %{ $self->{data} };
}

sub get {
    my ($self, $pauseid) = @_;
    return $self->{data}->{ $pauseid };
}

sub load {
    my ($class, $file) = @_;

    $file = Path::Tiny::path( $file )
        unless Scalar::Util::blessed( $file )
            && $file->isa('Path::Tiny');

    my $self = $class->_new( file => $file );
    my $data = $self->{data};

    my $fh = IO::Zlib->new( $file->stringify, "rb" );
    die "Failed to read $file: $!" unless $fh;
    my @lines = <$fh>;
    $fh->close;

    foreach my $line ( @lines ) {
        my ( $alias, $pauseid, $long ) = split ' ', $line, 3;
        $long =~ s/^"//;
        $long =~ s/"$//;
        my ($name, $email) = $long =~ /(.*) <(.+)>$/;

        $data->{$pauseid} = {
            pauseid => $pauseid,
            name    => $name,
            email   => $email,
        };
    }

    return $self;
}

sub store {
    my $self  = shift;
    my $out   = IO::Zlib->new( $self->{file}->stringify, 'wb' );
    my %index = %{ $self->{data} };

    foreach my $pauseid ( sort keys %index ) {
        $out->print(
            sprintf "alias %s \"%s <%s>\"\n" => (
                $pauseid,
                $index{$pauseid}->{name},
                $index{$pauseid}->{email},
            )
        );
    }
    $out->close;

    return $self;
}

1;

__END__

# ABSTRACT: Interface to the Author data (01mailrc.txt.gz)

=pod

=head1 DESCRIPTION

=cut
