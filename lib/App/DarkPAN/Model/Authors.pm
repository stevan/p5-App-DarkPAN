package App::DarkPAN::Model::Authors;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'App::DarkPAN::Model::Core::CompressedDataFile';

## ... overridden methods 

sub fetch_all {
    my ($self) = @_;
    return sort { $a->{pauseid} cmp $b->{pauseid} } $self->SUPER::fetch_all;    
}

sub fetch {
    my ($self, $pauseid) = @_;
    return $self->SUPER::fetch( qr/^alias $pauseid\s/ )
}

sub find {
    my ($self, $pauseid_pattern) = @_;
    return $self->SUPER::fetch( qr/^alias $pauseid_pattern/ );
}

sub upsert {
    my ($self, $author) = @_;
    my $pauseid = $author->{pauseid};
    return $self->SUPER::upsert( qr/^alias $pauseid\s/, $author );
}

sub delete {
    my ($self, $pauseid) = @_;
    return $self->SUPER::delete( qr/^alias $pauseid\s/ );
}

## ... abstract methods

sub unpack_line_into_data {
    my ($self, $line) = @_;
    
    my ($pauseid, $name, $email) = $line =~ /^alias ([A-Z0-9_-]+)\s+\"(.*) <(.+)>\"$/;   
    die "Unable to parse line: $line" unless $pauseid;
    
    return +{
        pauseid => $pauseid,
        name    => $name,
        email   => $email,
    };
}

sub pack_data_into_line {
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
