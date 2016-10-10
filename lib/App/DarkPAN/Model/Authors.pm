package App::DarkPAN::Model::Authors;

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
    my ($self, $new_author) = @_;
    return $self->SUPER::insert( $new_author );
}

sub update {
    my ($self, $new_author, $key, $pattern) = @_;
    die 'You must specify a key/pattern pair when updating'
        unless ($key && $pattern);
    return $self->SUPER::update( 
        $self->_regexp_match_builder( $key, $pattern ), 
        $new_author
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

## ... private methods

sub _regexp_match_builder {
    my ($self, $key, $pattern) = @_;
    return qr/^alias $pattern\s/    if $key eq 'pauseid';
    return qr/\"$pattern \<.+\>\"$/ if $key eq 'name';
    return qr/\<$pattern\>\"$/      if $key eq 'email';
    die 'Unknown key: ' . $key;
}

1;

__END__

# ABSTRACT: Interface to the Author data (01mailrc.txt.gz)

=pod

=head1 DESCRIPTION

=cut
