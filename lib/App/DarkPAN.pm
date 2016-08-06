package App::DarkPAN;

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# load our CONFIG first, ...

our %CONFIG;
BEGIN {
    $CONFIG{'DEBUG'}   = $ENV{'DARKPAN_DEBUG'}   // 0;
    $CONFIG{'VERBOSE'} = $ENV{'DARKPAN_VERBOSE'} // 0;
}

use App::Cmd::Setup -app => {
    plugins => [
        'Prompt'
    ]
};

1;

__END__

=pod

=cut
