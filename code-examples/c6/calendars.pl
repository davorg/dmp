use strict;
use warnings;
use DateTime;
use DateTime::Calendar::Hijri;
use DateTime::Calendar::Hebrew;

my $today = DateTime->today;

my $hijri  = DateTime::Calendar::Hijri->from_object(object => $today);
my $hebrew = DateTime::Calendar::Hebrew->from_object(object => $today);

print "Gregorian: ", $today, "\n";
print "Hijri:     ", $hijri->datetime, "\n";
print "Hebrew:    ", $hebrew->ymd, "\n";
