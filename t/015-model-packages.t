#!perl

use strict;
use warnings;

use Test::More;

use Path::Tiny ();

BEGIN {
    use_ok('App::DarkPAN::Model');
}

my $Moose = {
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
    ok(not( -e $packages_file ), '... the file has not been created yet');

    $packages->store;
    ok(-e $packages_file, '... the file has now been created');
};

subtest '... reading empty packages model, adding to it and saving' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    $packages->set('Moose' => $Moose);

    my $data = $packages->get('Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');

    $packages->store;
};

subtest '... reading packages model confirming the above worked' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    my $data = $packages->get('Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');

    my @all = $packages->get_all;
    is(scalar(@all), 1, '... there is only one author in the list');
    is_deeply($all[0], { package => 'Moose', %$Moose }, '... got the data back out with package added');
};


done_testing;
