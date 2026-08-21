use strict;
use warnings;
use DateTime;
use DateTime::Format::HTTP;

my $now = DateTime->now;
print DateTime::Format::HTTP->format_datetime($now);
print "\n";
