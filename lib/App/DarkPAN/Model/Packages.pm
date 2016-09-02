package App::DarkPAN::Model::Packages;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'App::DarkPAN::Model::Core::CompressedDataFile';

## ... overridden methods 

sub fetch_all {
    my ($self) = @_;
    return sort { $a->{package} cmp $b->{package} } $self->SUPER::fetch_all;    
}

sub fetch {
    my ($self, $name) = @_;
    return $self->SUPER::fetch( qr/^$name\s/ )
}

sub find {
    my ($self, $name_pattern) = @_;
    return $self->SUPER::fetch( qr/^$name_pattern/ );
}

sub upsert {
    my ($self, $package) = @_;
    my $package_name = $package->{package};
    return $self->SUPER::upsert( qr/^$package_name\s/, $package );
}

sub delete {
    my ($self, $package_name) = @_;
    return $self->SUPER::delete( qr/^$package_name\s/ );
}

sub open_file_for_reading {
    my ($self, $file) = @_;
    my $fh = $self->SUPER::open_file_for_reading( $file );
    $self->_skip_package_file_header( $fh );
    return $fh;
}

sub open_file_for_writing {
    my ($self, $file) = @_;
    my $fh = $self->SUPER::open_file_for_writing( $file );
    $self->_write_package_file_header( $fh );
    return $fh;
}

# ... abstract methods

sub unpack_line_into_data {
    my ($self, $line) = @_;
    
    my ( $name, $version, $dist_filename ) = split ' ', $line;  
    die "Unable to parse line: $line" unless $name;
    
    return +{
        package       => $name,
        version       => $version,
        dist_filename => $dist_filename,
    };
}

sub pack_data_into_line {
    my ($self, $package) = @_;
    return sprintf
        "%-34s %5s  %s\n",
        $package->{package},
        $package->{version} // 'undef',
        $package->{dist_filename}
    ;
}

## ... private methods 

sub _skip_package_file_header {
    my ($self, $fh) = @_;
    
    while ( my $line = $fh->getline ) {
        last if $line =~ /^\s*$/;        # last if blank line
        next if $line =~ /^[^:]+:\s*.*/; # continue if in `key: value` still
    }
    
    return;
}

sub _write_package_file_header {
    my ($self, $fh) = @_;

    my @header = (
        'File'         => '02packages.details.txt',
        'URL'          => $self->{file}->stringify,
        'Description'  => 'Package names found in directory $CPAN/authors/id/',
        'Columns'      => 'package name, version, path',
        'Intended-For' => 'Automated fetch routines, namespace documentation.',
        'Written-By'   => (Scalar::Util::blessed($self).' version '.$self->VERSION),
        'Last-Updated' => ((scalar gmtime).' GMT'),
        # FIXME: 
        # We want to write this very early
        # which is a problem, so we need to 
        # think about how to handle this.
        # - SL
        # 'Line-Count'   => $line_count,
    );

    while (@header) {
        my ($key, $value) = (shift(@header), shift(@header));
        $fh->print( sprintf "%15s %s\n" => ($key.':'), $value );
    }
    
    # add in the blank line
    $fh->print("\n");

    return;
}

1;

__END__

# ABSTRACT: Interface to the Package data (02packages.details.txt.gz)

=pod

=head1 DESCRIPTION

=cut
