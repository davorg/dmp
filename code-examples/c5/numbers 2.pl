my $num_re = qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/;

my @nums;

while ($data =~ /($num_re)/g) {
  push @nums, $1;
}
