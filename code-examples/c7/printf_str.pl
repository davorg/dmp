my @formats = qw(%s %10s %010s %-10s %-010s); 

my $str = 'Text'; 

foreach (@formats) { 
  printf "¦$_¦\n", $str; 
}
