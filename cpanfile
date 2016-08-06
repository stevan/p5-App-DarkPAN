
# Dependencies
requires 'App::Cmd'                  => '0.328';
requires 'App::Cmd::Plugin::Prompt'  => '0';
requires 'Path::Tiny'                => '0';

requires 'Parse::CPAN::Packages'     => '0';
requires 'Parse::CPAN::Authors'      => '0';
requires 'Parse::CPAN::Modlist'      => '0';

# Core
requires 'FindBin'                   => '0';
requires 'Scalar::Util'              => '0';
requires 'Carp'                      => '0';

# Development
requires 'Carp::Always'              => '0';

# Testing
requires 'Test::More'                => '0';

# ---------------------------------------------------------
# TO BE REPLACED
# ---------------------------------------------------------

requires 'CPAN::Faker'               => '0';
requires 'CPAN::Mini'                => '0';
requires 'CPAN::Mini::Inject'        => '0';

