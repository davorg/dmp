my @cols = qw(5 25 33 39 40 48); 

while (<STDIN>) { 
  my @rec; 
  my $prev = 0; 

  foreach my $col (@cols) { 
    push @rec, substr($_, $prev, $col - $prev); 
    $prev = $col; 
  } 

  print join('¦', @rec); 
  print "\n"; 
}

