use Regexp::Common;

for my $candidate ('192.168.0.1', '999.1.1.1', 'not an address') {
  if ($candidate =~ /^$RE{net}{IPv4}$/) {
    print "$candidate: valid IPv4 address\n";
  } else {
    print "$candidate: not a valid IPv4 address\n";
  }
}
