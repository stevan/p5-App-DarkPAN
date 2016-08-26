package App::DarkPAN::Model::Authors;

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

sub fetch_all {
    my $self = $_[0];
    return sort { $a->{pauseid} cmp $b->{pauseid} } $self->_load_all;
}

sub fetch {
    my ($self, $pauseid) = @_;
    return $self->_load_one( $pauseid );
}

sub find {
    my ($self, $pauseid_pattern) = @_;
    return $self->_load_all_matches( $pauseid_pattern );
}

sub upsert {
    my ($self, $author) = @_;
    
    my $found   = 0;
    my $pauseid = $author->{pauseid};
    
    $self->_write_changes(
        per_line => sub {
            my ($input) = @_;
            if ( $input =~ /^alias $pauseid\s/ ) {
                # just replace it with the new author 
                # info if we match it 
                $found++;          
                return $self->_unparse_line( $author );    
            }
            # otherwise just pass through ...
            return $input;
        },
        post => sub {
            my ($in, $out) = @_;
            # if we didn't find it already, it is 
            # new so we need to add it to the end.
            $out->print( $self->_unparse_line( $author ) )
                unless $found;
        }
    );
    
    return;
}

sub delete {
    my ($self, $pauseid) = @_;
    
    $self->_write_changes(
        per_line => sub {
            my ($input) = @_;
            # return nothing, so we skip the line ...
            return if $input =~ /^alias $pauseid\s/;
            # otherwise just pass through ....
            return $input;
        },
    );
    
    return;
}

## ...

sub _open_file_for_reading {
    my ($self, $file) = @_;
    my $fh = IO::Zlib->new( $file->stringify, 'rb' );
    die "Failed to open file for reading - $file: $!" unless $fh;
    return $fh;
}

sub _open_file_for_writing {
    my ($self, $file) = @_;
    my $fh = IO::Zlib->new( $file->stringify, 'wb' );
    die "Failed to open file for writing - $file: $!" unless $fh;
    return $fh;
}

## ...

sub _load_all {
    my ($self) = @_;
    
    my $fh = $self->_open_file_for_reading( $self->{file} );
    
    my @authors;
    while ( my $line = $fh->getline ) {
        push @authors => $self->_parse_line( $line );
    }
    
    $fh->close;
    
    return @authors;
}

sub _load_one {
    my ($self, $pauseid) = @_;
    
    my $fh = $self->_open_file_for_reading( $self->{file} );
    
    my $author;
    while ( my $line = $fh->getline ) {
        if ( $line =~ /^alias $pauseid\s/) {    
            $author = $self->_parse_line( $line );
            last;
        }
    }
    
    $fh->close;
    
    return $author;
}

sub _load_all_matches {
    my ($self, $pauseid_pattern) = @_;
    
    my $fh = $self->_open_file_for_reading( $self->{file} );
    
    my @authors;
    while ( my $line = $fh->getline ) {
        if ( $line =~ /^alias $pauseid_pattern/) {    
            push @authors => $self->_parse_line( $line );
        }
    }
    
    $fh->close;
    
    return @authors;
}

sub _write_changes {
    my ($self, %args) = @_;

    my $per_line = $args{per_line} || die 'You must at least supply a per_line handler'; 
    my $pre      = $args{pre};
    my $post     = $args{post};

    my $temp = Path::Tiny->tempfile;
    my $in   = $self->_open_file_for_reading( $self->{file} );
    my $out  = $self->_open_file_for_writing( $temp );

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

## ...

sub _parse_line {
    my ($self, $line) = @_;
    
    my ($pauseid, $name, $email) = $line =~ /^alias ([A-Z0-9_-]+)\s+\"(.*) <(.+)>\"$/;   
    die "Unable to parse line: $line" unless $pauseid;
    
    return +{
        pauseid => $pauseid,
        name    => $name,
        email   => $email,
    };
}

sub _unparse_line {
    my ($self, $author) = @_;
    return sprintf "alias %s \"%s <%s>\"\n" => (
        $author->{pauseid},
        $author->{name}  // '',
        $author->{email} // '',
    );
}

1;

__END__

# ABSTRACT: Interface to the Author data (01mailrc.txt.gz)

=pod

=head1 DESCRIPTION

=cut
