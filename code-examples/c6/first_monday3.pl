use strict;
use warnings;
use DateTime;

my $year = shift // DateTime->now->year;

my $first_mon = DateTime->new(
    year  => $year,
    month => 1,
    day   => 1,
);

my $days = (8 - $first_mon->day_of_week) % 7;

print $first_mon->add(days => $days);
print "\n";
