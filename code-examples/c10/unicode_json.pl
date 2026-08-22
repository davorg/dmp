use strict;
use warnings;
use utf8;
use JSON::MaybeXS;

binmode STDOUT, ':encoding(UTF-8)';

my $bytes = encode_json({ artist => 'Björk' });   # UTF-8 bytes, correctly

my $right = decode_json($bytes);                  # bytes in, chars out: correct
my $wrong = JSON->new->decode($bytes);             # chars expected, bytes given: wrong

print "Right: $right->{artist} (", length($right->{artist}), " chars)\n";
print "Wrong: $wrong->{artist} (", length($wrong->{artist}), " chars)\n";
