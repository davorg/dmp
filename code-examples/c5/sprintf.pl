my $number = 123.456789; 

my @fmts = ('0.2f', '.2f', '10.4f', '-10.4f'); 

foreach (@fmts) { 
  my $fmt = sprintf "%$_", $number; 
  print "$_: [$fmt]\n"; 
}
