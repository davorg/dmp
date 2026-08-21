use strict;
use warnings;
use utf8;

binmode STDOUT, ':encoding(UTF-8)';

my $π = 3.14159;
my $r = 5;

print "A circle of radius $r has an area of ", $π * $r ** 2, "\n";
