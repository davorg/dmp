use strict;
use warnings;
use v5.36;
use Test::More;

sub trim($str) {
  $str =~ s/^\s+|\s+$//g;
  return $str;
}

is(trim('  hello  '), 'hello', 'removes leading and trailing spaces');
is(trim('no spaces'), 'no spaces', 'leaves an already-trimmed string alone');
ok(!length(trim('   ')), 'a string of just spaces trims to empty');
like(trim('  data munging  '), qr/^data/, 'trimmed string starts with "data"');

done_testing();
