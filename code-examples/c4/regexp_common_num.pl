use Regexp::Common;

for my $candidate ('3.14', '-42', 'hello', '1e10') {
  if ($candidate =~ /^$RE{num}{real}$/) {
    print "$candidate: valid number\n";
  } else {
    print "$candidate: not a number\n";
  }
}
