my %templates = (ADD => {len => 35, 
			 tem => 'a4A14a6a5a6'}, 
		 DEL => {len => 18, 
			 tem => 'a4A14'}); 

my $type; 

while (read STDIN, $type, 3) { 
  read STDIN, $data, $templates{$type}->{len}; 
  my @rec = unpack($templates{$type}->{tem}, $data); 

  print "$type - ", join('¦', @rec); 
  print "\n"; 
}
