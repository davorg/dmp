my @widths = qw(5 20 8 6 1 8); 

my $regex; 

$regex .= "(.{$_})" foreach @widths; 

while (<STDIN>) { 
  my @rec = /$regex/; 
  print join('¦', @rec); 
  print "\n"; 
}
