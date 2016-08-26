#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('App::DarkPAN');

    use_ok('App::DarkPAN::Model');

        use_ok('App::DarkPAN::Model::Authors');

    use_ok('App::DarkPAN::Command');

        use_ok('App::DarkPAN::Command::init');

        use_ok('App::DarkPAN::Command::inject');
        use_ok('App::DarkPAN::Command::submit');

        use_ok('App::DarkPAN::Command::authors');
        use_ok('App::DarkPAN::Command::packages');

        use_ok('App::DarkPAN::Command::tutorial');
}

done_testing;
