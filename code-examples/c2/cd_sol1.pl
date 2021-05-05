my %years; 
while (<STDIN>) { 
  chomp; 
  my $year = (split /\t/)[3]; 
  $years{$year}++; 
} 

foreach (sort keys %years) { 
  print "In $_, $years{$_} CDs were released.\n"; 
}
