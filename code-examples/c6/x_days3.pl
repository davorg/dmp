use strict;
use warnings;
use DateTime;

my $days = shift // 10;

my $now = DateTime->now;
print $now->add(days => $days)->strftime('%a %b %d %H:%M:%S %Y');
print "\n";
