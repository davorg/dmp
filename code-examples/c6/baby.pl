use strict;
use warnings;
use DateTime;
use DateTime::Format::Baby;

my $baby = DateTime::Format::Baby->new('en');
print $baby->format_datetime(DateTime->now);
print "\n";
