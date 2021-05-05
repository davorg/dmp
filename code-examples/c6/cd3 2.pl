$/ = "%%\n";

my @CDs;

while (<STDIN>) {
  chomp;
  my (%CD, $field);

  my @fields = split(/\n/);
  foreach $field (@fields) {
    my ($key, $val) = split (/:\s*/, $field, 2);
    $CD{lc $key} = $val;
  }

  push @CDs, \%CD;
}
