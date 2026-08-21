use strict;
use warnings;
use utf8;

binmode STDOUT, ':encoding(UTF-8)';

my $ident = 'foo_1';
print $ident =~ /^\w+$/    ? "matches \\w\n"    : "no match\n";
print $ident =~ /^\p{L}+$/ ? "matches \\p{L}\n" : "no match\n";

my $greek = 'χρόνος';
print $greek =~ /^\p{Greek}+$/ ? "all Greek\n" : "not all Greek\n";

print 'café' =~ /^\p{Greek}+$/ ? "all Greek\n" : "not all Greek\n";

(my $stripped = 'Björk-1975!') =~ s/\P{L}//g;
print "$stripped\n";
