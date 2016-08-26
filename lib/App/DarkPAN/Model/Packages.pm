package App::DarkPAN::Model::Packages;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use CPAN::DistnameInfo ();

use parent 'App::DarkPAN::Model::Core::CompressedDataFile';

## ...

sub fetch_all {
    my ($self) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my @packages;
    while ( my $line = $fh->getline ) {
        push @packages => $self->_parse_line( $line );
    }
    
    $fh->close;
    
    return sort { $a->{package} cmp $b->{package} } @packages;    
}

sub fetch {
    my ($self, $name) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my $package;
    while ( my $line = $fh->getline ) {
        if ( $line =~ /^$name\s/) {
            $package = $self->_parse_line( $line );
            last;
        }
    }
    
    $fh->close;
    
    return $package;
}

sub find {
    my ($self, $name_pattern) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my @packages;
    while ( my $line = $fh->getline ) {
        if ( $line =~ /^$name_pattern/) {    
            push @packages => $self->_parse_line( $line );
        }
    }
    
    $fh->close;
    
    return @packages;
}

sub upsert {
    my ($self, $package) = @_;
    
    my $found        = 0;
    my $package_name = $package->{package};
    
    $self->write_changes_to_file(
        per_line => sub {
            my ($input) = @_;
            if ( $input =~ /^$package_name\s/ ) {
                # just replace it with the new package
                # info if we match it 
                $found++;          
                return $self->_unparse_line( $package );    
            }
            # otherwise just pass through ...
            return $input;
        },
        post => sub {
            my ($in, $out) = @_;
            # if we didn't find it already, it is 
            # new so we need to add it to the end.
            $out->print( $self->_unparse_line( $package ) )
                unless $found;
        }
    );
    
    return;
}

sub delete {
    my ($self, $package_name) = @_;
    
    $self->write_changes_to_file(
        per_line => sub {
            my ($input) = @_;
            # return nothing, so we skip the line ...
            return if $input =~ /^$package_name\s/;
            # otherwise just pass through ....
            return $input;
        },
    );
    
    return;
}

## ...

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

## ...

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

# ...

sub _parse_line {
    my ($self, $line) = @_;
    
    my ( $name, $version, $dist_filename ) = split ' ', $line;  
    die "Unable to parse line: $line" unless $name;
    
    return +{
        package       => $name,
        version       => $version,
        dist_filename => $dist_filename,
    };
}

sub _unparse_line {
    my ($self, $package) = @_;
    return sprintf
        "%-34s %5s  %s\n",
        $package->{package},
        $package->{version} // 'undef',
        $package->{dist_filename}
    ;
}


1;

__END__

# ABSTRACT: Interface to the Package data (02packages.details.txt.gz)

=pod

=head1 DESCRIPTION

=cut
