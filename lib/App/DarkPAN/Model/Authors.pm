package App::DarkPAN::Model::Authors;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'App::DarkPAN::Model::Core::CompressedDataFile';

## ...

sub fetch_all {
    my ($self) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my @authors;
    while ( my $line = $fh->getline ) {
        push @authors => $self->_parse_line( $line );
    }
    
    $fh->close;
    
    return sort { $a->{pauseid} cmp $b->{pauseid} } @authors;    
}

sub fetch {
    my ($self, $pauseid) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
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

sub find {
    my ($self, $pauseid_pattern) = @_;
    
    my $fh = $self->open_file_for_reading( $self->{file} );
    
    my @authors;
    while ( my $line = $fh->getline ) {
        if ( $line =~ /^alias $pauseid_pattern/) {    
            push @authors => $self->_parse_line( $line );
        }
    }
    
    $fh->close;
    
    return @authors;
}

sub upsert {
    my ($self, $author) = @_;
    
    my $found   = 0;
    my $pauseid = $author->{pauseid};
    
    $self->write_changes_to_file(
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
    
    $self->write_changes_to_file(
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

## ....

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
