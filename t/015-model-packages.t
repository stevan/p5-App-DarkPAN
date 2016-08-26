#!perl

use strict;
use warnings;

use Test::More;

use Path::Tiny ();

BEGIN {
    use_ok('App::DarkPAN::Model');
}

my $Moose = {
    package       => 'Moose',
    version       => '0.01',
    dist_filename => 'authors/id/S/ST/STEVAN/Moose-0.01.tar.gz'
};

my $temp_dir = Path::Tiny->tempdir;

subtest '... creating simple packages model' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    my $packages_file = $temp_dir->child('CPAN/modules/02packages.details.txt.gz');
    ok(-e $packages_file, '... the file has been created yet');
    is(0, -s $packages_file, '... the file but it is empty');
};

subtest '... reading empty packages model, adding to it and saving' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    $packages->upsert($Moose);

    my $data = $packages->fetch('Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');
};

subtest '... reading packages model confirming the above worked' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    my $data = $packages->fetch('Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');

    my @all = $packages->fetch_all;
    is(scalar(@all), 1, '... there is only one author in the list');
    is_deeply($all[0], $Moose, '... got the data back out with package added');
};


done_testing;
