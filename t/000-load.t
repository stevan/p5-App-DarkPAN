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

        use_ok('App::DarkPAN::Command::repo_inject');
        use_ok('App::DarkPAN::Command::repo_review');
        use_ok('App::DarkPAN::Command::repo_submit');

        use_ok('App::DarkPAN::Command::data_select');
        use_ok('App::DarkPAN::Command::data_upsert');
        use_ok('App::DarkPAN::Command::data_delete');

        use_ok('App::DarkPAN::Command::tutorial');
}

done_testing;
