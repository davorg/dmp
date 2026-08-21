use strict;
use warnings;
use Time::Piece;
use Time::Seconds;

my $year = shift // localtime->year;

my $first_mon = Time::Piece->strptime("$year Jan 1", '%Y %b %e');

$first_mon += (8 - $first_mon->day_of_week) % 7 * ONE_DAY;

print $first_mon;
print "\n";
