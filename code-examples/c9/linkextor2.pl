use HTML::LinkExtor; 

my $file = shift; 
my $p = HTML::LinkExtor->new(\&check); 

$p->parse_file($file); 

my @links; 
foreach (@links) { 
  print 'Type: ', shift @$_, "\n"; 
  while (my ($name, $val) = splice(@$_, 0, 2)) { 
    print " $name -> $val\n"; 
  } 
} 

sub check { 
  push @links, [@_] if $_[0] eq 'a'; 
}
