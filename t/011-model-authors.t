#!perl

use strict;
use warnings;

use Test::More;

use Path::Tiny ();

BEGIN {
    use_ok('App::DarkPAN::Model');
}

my $STEVAN = { name => 'Stevan Little', email => 'stevan@cpan.org', pauseid => 'STEVAN' };

my $temp_dir = Path::Tiny->tempdir;

subtest '... creating simple authors model' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $authors = $m->authors;
    isa_ok($authors, 'App::DarkPAN::Model::Authors');

    my $authors_file = $temp_dir->child('CPAN/authors/01mailrc.txt.gz');
    ok(-e $authors_file, '... the file has been created yet');
    is(0, -s $authors_file, '... the file but it is empty');
};

subtest '... reading empty authors model, adding to it and saving' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $authors = $m->authors;
    isa_ok($authors, 'App::DarkPAN::Model::Authors');

    $authors->insert($STEVAN);

    my ($data) = $authors->select(pauseid => 'STEVAN');
    is_deeply($data, $STEVAN, '... got the same data back out');
    isnt($data, $STEVAN, '... but different instances');
};

subtest '... reading authors model confirming the above worked' => sub {

    my $m = App::DarkPAN::Model->new( root => $temp_dir );
    isa_ok($m, 'App::DarkPAN::Model');

    my $authors = $m->authors;
    isa_ok($authors, 'App::DarkPAN::Model::Authors');

    my ($data) = $authors->select(pauseid => 'STEVAN');
    is_deeply($data, $STEVAN, '... got the same data back out');
    isnt($data, $STEVAN, '... but different instances');

    my @all = $authors->select;
    is(scalar(@all), 1, '... there is only one author in the list');
    is_deeply($all[0], $STEVAN, '... got the data back out');
};


done_testing;
