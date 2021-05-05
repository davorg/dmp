my $template = 'a5a20a8a6aa8'; 

while (<STDIN>) { 
  my @rec = unpack($template, $_); 
  print join('¦', @rec); 
  print "\n"; 
}
