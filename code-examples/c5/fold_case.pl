use strict;
use warnings;
use utf8;
use feature 'fc';

my @words = ('straße', 'STRASSE');

print "lc: ", (lc($words[0]) eq lc($words[1]) ? 'equal' : 'not equal'), "\n";
print "fc: ", (fc($words[0]) eq fc($words[1]) ? 'equal' : 'not equal'), "\n";
