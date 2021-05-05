my @formats = qw(%f %6.2f %06.2f); 

my $num = 12.3; 

foreach (@formats) { 
  printf "¦$_¦\n", $num; 
}
