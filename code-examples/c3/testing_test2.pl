use v5.36;
use Test2::V0;

sub trim($str) {
  $str =~ s/^\s+|\s+$//g;
  return $str;
}

# The same tests as before: is(), ok() and like() work as they do in Test::More
is(trim('  hello  '), 'hello', 'removes leading and trailing spaces');
is(trim('no spaces'), 'no spaces', 'leaves an already-trimmed string alone');
ok(!length(trim('   ')), 'a string of just spaces trims to empty');
like(trim('  data munging  '), qr/^data/, 'trimmed string starts with "data"');

# New: is() compares whole data structures
sub parse_cd($line) {
  my ($artist, $title, $label, $year) = split /\t/, $line;
  return { artist => $artist, title => $title, label => $label, year => $year };
}

my $cd = parse_cd("Bowie, David\tBlackstar\tColumbia\t2016");

is($cd,
   { artist => 'Bowie, David', title => 'Blackstar',
     label  => 'Columbia',     year  => 2016 },
   'a CD line is parsed into the right hash');

# like() on a hash only checks the keys you mention
like($cd, { artist => 'Bowie, David', year => 2016 },
     'the artist and year are right (we don\'t care about the rest)');

done_testing();
