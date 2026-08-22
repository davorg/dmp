use strict;
use warnings;
use utf8;
use Unicode::Collate;

binmode STDOUT, ':encoding(UTF-8)';

my @words = ('über', 'apple', 'zebra');

print "Default sort:  ", join(', ', sort @words), "\n";

my $collator = Unicode::Collate->new;
print "Collated sort: ", join(', ', $collator->sort(@words)), "\n";
