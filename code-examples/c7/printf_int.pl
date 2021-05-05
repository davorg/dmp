my @formats = qw(%d %5d %05d); 

my $num = 123; 

foreach (@formats) { 
  printf "¦$_¦\n", $num; 
}
