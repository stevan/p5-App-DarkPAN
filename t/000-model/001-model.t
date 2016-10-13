#!perl

use strict;
use warnings;

use Test::More;

use Path::Tiny ();

BEGIN {
    use_ok('App::DarkPAN::Model');
}

subtest '... testing model' => sub {
    my $temp_dir = Path::Tiny->tempdir;

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    # ...
};

done_testing;
