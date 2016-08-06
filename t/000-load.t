#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('App::DarkPAN');

    use_ok('App::DarkPAN::Command::init');
}

done_testing;
