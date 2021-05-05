my $template = 'A5A20A8A6AA8'; 

my $data; 
while (read STDIN, $data, 48) { 
  my @rec = unpack($template, $data);

  print join('¦', @rec); 
  print "\n"; 
}
