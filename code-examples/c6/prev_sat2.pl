use strict;
use warnings;
use Time::Piece;
use Time::Seconds;

my $now = localtime;
my $days = $now->day_of_week + 1;
print $now - ($days * ONE_DAY);
print "\n";
