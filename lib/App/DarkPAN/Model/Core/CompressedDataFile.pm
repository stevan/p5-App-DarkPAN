package App::DarkPAN::Model::Core::CompressedDataFile;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny   ();
use Scalar::Util ();
use IO::Zlib     ();

sub new {
    my ($class, %args) = @_;
    
    die $class.' is an abstract class and cannot be instantiated'
        if $class eq __PACKAGE__;
    
    die 'Cannot create model without a data file specified'
        if not defined $args{file};
    
    $args{file} = Path::Tiny::path( $args{file} )
        unless Scalar::Util::blessed( $args{file} )
            && $args{file}->isa('Path::Tiny');    

    # create the parent directory as needed...
    $args{file}->parent->mkpath unless -e $args{file}->parent;
    # and create the file as needed
    $args{file}->touch          unless -e $args{file};

    return bless {
        file => $args{file},
    } => $class;
}

sub file { $_[0]->{file} }

## ... abstract methods

sub unpack_line_into_data;
sub   pack_data_into_line;

## ...

sub count {
    my ($self, $pattern) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my $count = 0;
    while ( my $line = $fh->getline ) {
        next unless $line;
        next if $pattern && $line !~ m/$pattern/;
        $count++;
    }
    
    $fh->close;
    
    return $count;
}

sub select {
    my ($self, $pattern) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my @data;
    while ( my $line = $fh->getline ) {
        next unless $line;
        next if $pattern && $line !~ m/$pattern/;
    
        push @data => $self->unpack_line_into_data( $line );
    }
    
    $fh->close;
    
    return @data;
}

sub insert {
    my ($self, $data) = @_;
    
    my $new_line = $self->pack_data_into_line( $data );
    
    $self->write_changes_to_file(
        operation => 'insert',
        pre  => sub {
            my ($in, $out, $lines, $args) = @_;
            die "Cannot insert duplicate record:\n\t${new_line}"
                if scalar grep $_ eq $new_line, @$lines;
        },
        post => sub {
            my ($in, $out, $lines, $args) = @_;
            # just append this to the end of the document ...
            $out->print( $new_line );
        }
    );
    
    return;
}

sub update {
    my ($self, $pattern, $data) = @_;
    
    my $found = 0;
    $self->write_changes_to_file(
        operation => 'update',
        pattern   => $pattern,
        per_line  => sub {
            my ($input, $idx) = @_;
            
            if ( $input =~ m/$pattern/ ) {
                # just replace it with the new item
                # info if we match it 
                $found++;          
                return $self->pack_data_into_line({ 
                    %{ $self->unpack_line_into_data( $input ) },
                    %{ $data }
                });    
            }
            # otherwise just pass through ...
            return $input;
        },
        post => sub {
            my ($in, $out, $lines, $args) = @_;
            # if we didn't find it already, we 
            # need to complain loudly 
            die 'Unable to locate match (' . $pattern . ') for record' 
                unless $found;
        }
    );
    
    return;
}

sub delete {
    my ($self, $pattern) = @_;
    
    $self->write_changes_to_file(
        operation => 'delete',
        pattern   => $pattern,
        per_line  => sub {
            my ($input, $idx) = @_;
            # return nothing, so we skip the line ...
            return if $input =~ m/$pattern/;
            # otherwise just pass through ....
            return $input;
        },
    );
    
    return;
}

## ...

sub open_file_for_reading {
    my ($self, $file) = @_;
    my $fh = IO::Zlib->new( $file->stringify, 'rb' );
    die "Failed to open file for reading - $file: $!" unless $fh;
    return $fh;
}

sub open_file_for_writing {
    my ($self, $file) = @_;
    my $fh = IO::Zlib->new( $file->stringify, 'wb' );
    die "Failed to open file for writing - $file: $!" unless $fh;
    return $fh;
}

sub write_changes_to_file {
    my ($self, %args) = @_;

    # this is not used here, but it 
    # must get passed along to the 
    # callbacks later on
    $args{operation} || die 'You must supply a operation type'; 

    my $per_line = $args{per_line} || sub { $_[0] };
    my $pre      = $args{pre};
    my $post     = $args{post};

    my $temp  = Path::Tiny->tempfile;
    my $in    = $self->open_file_for_reading( $self->{file} );
    my $out   = $self->open_file_for_writing( $temp );
    my @lines = $in->getlines;

    $pre->( $in, $out, \@lines, \%args ) if $pre;
    
    #use Data::Dumper;
    #warn Dumper \@lines;
    #warn Dumper [ 0 .. $#lines ];
    #warn Dumper [ @lines[ 0 .. $#lines ] ];

    if ( @lines ) {
        foreach my $i ( 0 .. $#lines ) {    
            my $output = $per_line->( $lines[ $i ], $i );
            $out->print( $output ) if $output;
        }
    }

    $post->( $in, $out, \@lines, \%args ) if $post;

    $out->close;
    $in->close;

    $temp->move( $self->{file} )
        or die 'Changes Not Saved: Unable to replace old file with old one';
        
    return;
}


1;

__END__

# ABSTRACT: Interface to compressed (tar.gz) line-oriented data files

=pod

=head1 DESCRIPTION

=cut
