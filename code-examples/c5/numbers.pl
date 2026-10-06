my $num_re = qr/(?<num>[-+]?(?=\d|\.\d)\d*(?:\.\d*)?(?:[eE][-+]?\d+)?)/;
my @nums;
while ($data =~ /$num_re/g) {
  push @nums, $+{num};
}
