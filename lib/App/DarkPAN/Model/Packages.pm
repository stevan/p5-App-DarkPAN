package App::DarkPAN::Model::Packages;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny         ();
use Scalar::Util       ();
use IO::Zlib           ();
use CPAN::DistnameInfo ();

sub new; # use load or create

sub _new {
    my ($class, %args) = @_;

    return bless {
        file   => $args{file},
        header => {}, # TODO: add support for header data ..
        data   => {},
    } => $class;
}

## ...

sub get_all {
    my $self = $_[0];
    return
        sort { $a->{package} cmp $b->{package} }
        map  +{ %{$self->{data}->{ $_ } }, package => $_ },
        keys %{ $self->{data} };
}

sub get {
    my ($self, $package) = @_;
    return $self->{data}->{ $package };
}

sub has {
    my ($self, $package) = @_;
    return exists $self->{data}->{ $package };
}

sub set {
    my ($self, $package, $data) = @_;
    $self->{data}->{ $package } ||= {};
    foreach my $k ( keys %$data ) {
        $self->{data}->{ $package }->{ $k } = $data->{ $k };
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

    # TODO: handle header lines, but for
    # now, we just skip header lines
    while ( @lines ) {
        my $line = shift @lines;
        last if     $line =~ /^\s*$/;        # last if blank line
        next unless $line =~ /^[^:]+:\s*.*/; # continue if in `key: value` still
    }

    my $data = $self->{data};
    foreach my $line ( @lines ) {
        my ( $name, $version, $dist_filename ) = split ' ', $line;
        $data->{$name} = {
            version       => $version,
            dist_filename => $dist_filename,
        };
    }

    return $self;
}

sub store {
    my $self = shift;

    # create the parent directory as needed...
    $self->{file}->parent->mkpath unless -e $self->{file}->parent;

    my %index = %{ $self->{data} };
    my @lines = map sprintf(
        "%-34s %5s  %s\n",
        $_,
        $index{ $_ }->{version} // 'undef',
        $index{ $_ }->{dist_filename}
    ), sort keys %index;

    my $out = IO::Zlib->new( $self->{file}->stringify, 'wb' );
    die "Failed to open file for writing - $self->{file}: $!" unless $out;
    $out->print( $self->_package_file_header( scalar @lines ) );
    $out->print("\n"); # blank line
    $out->print( $_ ) foreach @lines;
    $out->close;

    return $self;
}

## ...

sub _package_file_header {
    my ($self, $line_count) = @_;

    my @header = (
        'File'         => '02packages.details.txt',
        'URL'          => $self->{file}->stringify,
        'Description'  => 'Package names found in directory $CPAN/authors/id/',
        'Columns'      => 'package name, version, path',
        'Intended-For' => 'Automated fetch routines, namespace documentation.',
        'Written-By'   => (__PACKAGE__.' version '.$VERSION),
        'Line-Count'   => $line_count,
        'Last-Updated' => ((scalar gmtime).' GMT'),
    );

    my $header = '';

    while (@header) {
        my ($key, $value) = (shift(@header), shift(@header));
        $header .= sprintf "%15s %s\n" => ($key.':'), $value;
    }

    return $header;
}

1;

__END__

# ABSTRACT: Interface to the Package data (02packages.details.txt.gz)

=pod

=head1 DESCRIPTION

=cut
