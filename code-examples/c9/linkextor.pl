use HTML::LinkExtor; 

my $file = shift; 
my $p = HTML::LinkExtor->new; 
$p->parse_file($file); 

my @links = $p->links; 

foreach (@links) { 
  print 'Type: ', shift @$_, "\n";
  while (my ($name, $val) = splice(@$_, 0, 2)) { 
    print " $name -> $val\n"; 
  } 
}
