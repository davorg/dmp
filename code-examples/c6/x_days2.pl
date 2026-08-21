use strict;
use warnings;
use Time::Piece;
use Time::Seconds;

my $days = shift // 10;

my $now = localtime;
print $now + ($days * ONE_DAY);
print "\n";
