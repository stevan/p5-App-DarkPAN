package App::DarkPAN::Command::tutorial;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use App::DarkPAN -command;

sub opt_spec      { return ([]) }
sub validate_args { 1 }
sub execute       { print $_[0]->description, "\n" }

1;

__END__

# ABSTRACT: Tutorial about how to setup and use a DarkPAN repository

=pod

=head1 DESCRIPTION

  > cd ~/DarkPAN/ # optionally we can add `--root ~/DarkPAN/` to all commands

  > darkpan init
  DarkPAN created in (~/DarkPAN/dpan)

  > darkpan list --authors --packages
  No authors.
  No packages.

  > darkpan submit --author DGOLDEN --file ~/Downloads/Path-Tiny-0.096.tar.gz

  > darkpan list --authors --packages
  No authors.
  No packages.

  > darkpan inject --review
  Found 2 modules.
  Path::Tiny 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz
  Path::Tiny::Error 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz

  > darkpan inject
  Found 2 modules.
  Path::Tiny 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz
  Path::Tiny::Error 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz
  Injected 2 modules into DarkPAN.


  > darkpan list --authors --packages
  Found 1 authors.
  DGOLDEN CENSORED Custom Non-CPAN author
  Found 2 packages.
  Path::Tiny 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz
  Path::Tiny::Error 0.096 D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz

  > cpanm --mirror ~/DarkPAN/CPAN/ --mirror-only Path::Tiny --force
  --> Working on Path::Tiny
  Fetching file:///Users/stevan/DarkPAN/CPAN/authors/id/D/DG/DGOLDEN/Path-Tiny-0.096.tar.gz ... OK
  Configuring Path-Tiny-0.096 ... OK
  Building and testing Path-Tiny-0.096 ... OK
  Successfully installed Path-Tiny-0.096 (upgraded from 0.072)
  1 distribution installed

=cut
