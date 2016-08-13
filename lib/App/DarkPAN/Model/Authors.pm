package App::DarkPAN::Model::Authors;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny   ();
use Scalar::Util ();
use IO::Zlib     ();

sub new; # use load or create

sub _new {
    my ($class, %args) = @_;

    return bless {
        file => $args{file},
        data => {},
    } => $class;
}

## ...

sub get_all {
    my $self = $_[0];
    return
        sort { $a->{pauseid} cmp $b->{pauseid} }
        map  { $self->{data}->{ $_ }->{pauseid} = $_; $self->{data}->{ $_ } }
        keys %{ $self->{data} };
}

sub get {
    my ($self, $pauseid) = @_;
    return $self->{data}->{ $pauseid };
}

sub has {
    my ($self, $pauseid) = @_;
    return exists $self->{data}->{ $pauseid };
}

sub set {
    my ($self, $pauseid, $data) = @_;
    $self->{data}->{ $pauseid } ||= {};
    foreach my $k ( keys %$data ) {
        $self->{data}->{ $pauseid }->{ $k } = $data->{ $k };
    }
}

## ...

sub load {
    my ($class, $file) = @_;

    $file = Path::Tiny::path( $file )
        unless Scalar::Util::blessed( $file )
            && $file->isa('Path::Tiny');

    my $self = $class->_new( file => $file );

    # if the file doesn't exist, then
    # we just create the object and
    # it will get created when saved
    return $self unless -e $file;

    my $fh = IO::Zlib->new( $self->{file}->stringify, 'rb' );
    die "Failed to open file for reading - $file: $!" unless $fh;
    my @lines = <$fh>;
    $fh->close;

    my $data = $self->{data};
    foreach my $line ( @lines ) {
        my ( $alias, $pauseid, $long ) = split ' ', $line, 3;
        $long =~ s/^"//;
        $long =~ s/"$//;
        my ($name, $email) = $long =~ /(.*) <(.+)>$/;

        $data->{$pauseid} = {
            name    => $name,
            email   => $email,
        };
    }

    return $self;
}

sub store {
    my $self = shift;

    # create the parent directory as needed...
    $self->{file}->parent->mkpath unless -e $self->{file}->parent;

    my $out = IO::Zlib->new( $self->{file}->stringify, 'wb' );
    die "Failed to open file for writing - $self->{file}: $!" unless $out;

    my %index = %{ $self->{data} };
    foreach my $pauseid ( sort keys %index ) {
        $out->print(
            sprintf "alias %s \"%s <%s>\"\n" => (
                $pauseid,
                $index{$pauseid}->{name}  // '',
                $index{$pauseid}->{email} // '',
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
