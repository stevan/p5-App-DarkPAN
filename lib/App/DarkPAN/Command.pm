package App::DarkPAN::Command;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Path::Tiny ();

use App::Cmd::Setup -command;

sub opt_spec {
    my ($class) = @_;
    return (
        [ 'root=s',    'darkpan root directory, defaults to current working directory', { default => Path::Tiny->cwd } ],
        [],
        [ 'verbose|v', 'display additional information', { default => $App::DarkPAN::CONFIG{'VERBOSE'}                     } ],
        [ 'debug|d',   'display debugging information',  { default => $App::DarkPAN::CONFIG{'DEBUG'}, implies => 'verbose' } ],
    );
}


1;

__END__

# ABSTRACT: Base command class

=pod

=head1 NAME

App::DarkPAN::Command - Base command class

=head1 DESCRIPTION

=cut
