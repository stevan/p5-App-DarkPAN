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

my $Moo = {
    package       => 'Moo',
    version       => '0.01',
    dist_filename => 'authors/id/S/ST/STEVAN/Moo-0.01.tar.gz'
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

    $packages->upsert($Moose, package => 'Moose');

    my ($data) = $packages->select(package => 'Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');
};

subtest '... reading packages model confirming the above worked' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');

    my ($data) = $packages->select(package => 'Moose');
    is_deeply($data, $Moose, '... got the same data back out');
    isnt($data, $Moose, '... but different instances');

    my @all = $packages->select;
    is(scalar(@all), 1, '... there is only one author in the list');
    is_deeply($all[0], $Moose, '... got the data back out with package added');
};

subtest '... checking the header'  => sub {
    
    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $packages = $m->packages;
    isa_ok($packages, 'App::DarkPAN::Model::Packages');
    
    {
        my @lines = IO::Zlib->new( $packages->file->stringify, 'r' )->getlines;
        #warn join '' => @lines;
    
        is(scalar( grep /Line\-Count\: 1/, @lines ), 1, '... we matched the line-count as expected');
    }
    
    $packages->upsert($Moo, package => 'Moo');
    
    {
        my @lines = IO::Zlib->new( $packages->file->stringify, 'r' )->getlines;
        #warn join '' => @lines;
    
        is(scalar( grep /Line\-Count\: 2/, @lines ), 1, '... we matched the (new) line-count as expected');
    }
    
    $packages->delete(package => 'Moo');
    
    {
        my @lines = IO::Zlib->new( $packages->file->stringify, 'r' )->getlines;
        #warn join '' => @lines;
    
        is(scalar( grep /Line\-Count\: 1/, @lines ), 1, '... we matched the (even newer) line-count as expected');
    }
};


done_testing;
