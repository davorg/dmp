my %years; 
while (<STDIN>) {
  next unless /-----/ .. /^$/;

  chomp; 
  my $year = (split /\t/)[3]; 
  next unless $year;
  $years{$year}++; 
} 

foreach (sort keys %years) { 
  print "In $_, $years{$_} CDs were released.\n"; 
}
