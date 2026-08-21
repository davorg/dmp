use strict;
use warnings;
use DateTime::Fiction::JRRTolkien::Shire;

my $shire = DateTime::Fiction::JRRTolkien::Shire->new(
    year  => 1419,
    month => 'Rethe',
    day   => 25,
);

print $shire->on_date;
print "\n";
