$/ = "%%\n";

my @CDs;

while (<STDIN>) {
  chomp;

  my %CD;
  my @fields = split(/\n/);
  foreach my $field (@fields) {
    my ($key, $val) = split (/:\s*/, $field, 2);
    $CD{lc $key} = $val;
  }

  push @CDs, \%CD;
}
