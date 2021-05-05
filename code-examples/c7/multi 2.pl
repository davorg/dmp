my %templates = (ADD => 'a4A14a6a5a6', 
		 DEL => 'a4A14'); 

while (<STDIN>) { 
  my ($type, $data) = unpack('a3a*', $_); 
  my @rec = unpack($templates{$type}, $data); 

  print "$type - ", join('¦', @rec); 
  print "\n"; 
}
