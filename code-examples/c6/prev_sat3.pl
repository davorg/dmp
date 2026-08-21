use strict;
use warnings;
use DateTime;

my $now = DateTime->now;
my $days = $now->day_of_week + 1;
print $now->subtract(days => $days);
print "\n";
