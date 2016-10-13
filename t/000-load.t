#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('App::DarkPAN');

    use_ok('App::DarkPAN::Model');

        use_ok('App::DarkPAN::Model::Authors');
        use_ok('App::DarkPAN::Model::Packages');
        
            use_ok('App::DarkPAN::Model::Core::CompressedDataFile');

    use_ok('App::DarkPAN::Command');

        use_ok('App::DarkPAN::Command::init');

        use_ok('App::DarkPAN::Command::repo::submit');
        use_ok('App::DarkPAN::Command::repo::review');
        use_ok('App::DarkPAN::Command::repo::accept');        

        use_ok('App::DarkPAN::Command::data::select');
        use_ok('App::DarkPAN::Command::data::insert');
        use_ok('App::DarkPAN::Command::data::update');
        use_ok('App::DarkPAN::Command::data::delete');

        use_ok('App::DarkPAN::Command::tutorial');
}

done_testing;
