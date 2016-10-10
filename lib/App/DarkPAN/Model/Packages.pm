package App::DarkPAN::Model::Packages;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'App::DarkPAN::Model::Core::CompressedDataFile';

## ... overridden methods 

sub select {
    my ($self, $key, $pattern) = @_;
    return $self->SUPER::select( 
        ($key && $pattern)
            ? $self->_regexp_match_builder( $key, $pattern ) 
            : ()
    );
}

sub insert {
    my ($self, $new_package) = @_;
    return $self->SUPER::insert( $new_package );
}

sub update {
    my ($self, $new_package, $key, $pattern) = @_;
    die 'You must specify a key/pattern pair when updating'
        unless ($key && $pattern);
    return $self->SUPER::update( 
        $self->_regexp_match_builder( $key, $pattern ), 
        $new_package
    );
}

sub delete {
    my ($self, $key, $pattern) = @_;
    die 'You must specify a key/pattern pair when deleting'
        unless ($key && $pattern);
    return $self->SUPER::delete(
        $self->_regexp_match_builder( $key, $pattern ), 
    );
}

# ...

sub open_file_for_reading {
    my ($self, $file) = @_;
    my $fh = $self->SUPER::open_file_for_reading( $file );
    # TODO: 
    # we should actually parse the headers 
    # and make them visible to the users
    # of this class.
    # - SL
    $self->_skip_package_file_header( $fh );
    return $fh;
}

sub write_changes_to_file {
    my $self = shift;
    $self->SUPER::write_changes_to_file(
        pre => sub {
            my ($in, $out, $lines, $args) = @_;
            
            my $line_count = scalar @{ $lines };
            
            if ( $args->{operation} eq 'delete' ) {
                my $num_matches = grep /$args->{pattern}/, @$lines;
                if ( $num_matches ) {
                    # we have a match, so we 
                    # decrement the line count
                    # by the number of matches ...
                    $line_count -= $num_matches;
                }
            }
            elsif ( $args->{operation} eq 'insert' ) {
                # inserts always increment by one ...
                $line_count++;
            }
            
            $self->_write_package_file_header( $out, $line_count ); 
        }, 
        @_,
    );
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

sub _regexp_match_builder {
    my ($self, $key, $pattern) = @_;
    return qr/^$pattern\s/            if $key eq 'package';
    return qr/^(.*)\s$pattern/        if $key eq 'version';
    return qr/^(.*)\s(.*)\s$pattern$/ if $key eq 'dist_filename';
    die 'Unknown key: ' . $key;
}

sub _skip_package_file_header {
    my ($self, $fh) = @_;
    
    while ( my $line = $fh->getline ) {
        last if $line =~ /^\s*$/;        # last if blank line
        next if $line =~ /^[^:]+:\s*.*/; # continue if in `key: value` still
    }
    
    return;
}

sub _write_package_file_header {
    my ($self, $fh, $line_count) = @_;

    my @header = (
        'File'         => '02packages.details.txt',
        'URL'          => $self->{file}->stringify,
        'Description'  => 'Package names found in directory $CPAN/authors/id/',
        'Columns'      => 'package name, version, path',
        'Intended-For' => 'Automated fetch routines, namespace documentation.',
        'Written-By'   => (Scalar::Util::blessed($self).' version '.$self->VERSION),
        'Last-Updated' => ((scalar gmtime).' GMT'),
        'Line-Count'   => $line_count,
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
