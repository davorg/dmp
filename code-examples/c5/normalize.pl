use strict;
use warnings;
use utf8;
use Unicode::Normalize;

binmode STDOUT, ':encoding(UTF-8)';

my $precomposed = "caf\x{E9}";     # e with acute, one code point
my $decomposed   = "cafe\x{301}";  # e, then a combining acute accent

print "Before: ", ($precomposed eq $decomposed ? 'yes' : 'no'), "\n";
print "After:  ", (NFC($precomposed) eq NFC($decomposed) ? 'yes' : 'no'), "\n";
