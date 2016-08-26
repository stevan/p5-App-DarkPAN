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
    
    die "Cannot create Author model without a file specified" 
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

## ...

sub fetch_all;
sub fetch;
sub find;
sub upsert;
sub delete;

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

    my $per_line = $args{per_line} || die 'You must at least supply a per_line handler'; 
    my $pre      = $args{pre};
    my $post     = $args{post};

    my $temp = Path::Tiny->tempfile;
    my $in   = $self->open_file_for_reading( $self->{file} );
    my $out  = $self->open_file_for_writing( $temp );

    $pre->( $in, $out ) if $pre;

    while ( my $input = $in->getline ) {    
        my $output = $per_line->( $input );
        $out->print( $output ) if $output;
    }

    $post->( $in, $out ) if $post;

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
