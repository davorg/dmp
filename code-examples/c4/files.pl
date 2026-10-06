open my $fh, '<', 'files.txt' or die "Can't open files.txt: $!";

while (<$fh>) {
  print if /\/davec\//;
}
