use strict;
use warnings;
use Test::More;

sub trim {
  my ($str) = @_;
  $str =~ s/^\s+|\s+$//g;
  return $str;
}

is(trim('  hello  '), 'hello', 'removes leading and trailing spaces');
is(trim('no spaces'), 'no spaces', 'leaves an already-trimmed string alone');
ok(!length(trim('   ')), 'a string of just spaces trims to empty');
like(trim('  data munging  '), qr/^data/, 'trimmed string starts with "data"');

done_testing();
