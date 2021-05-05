open MAIL, 'mail.txt' or die "Can't open mail.txt: $!"; 

my ($header, $value); 
while (<MAIL>) { 
  if (($header, $value) = /^([^:]+): ?(.+)$/) { 
    print "Header $header has the value $value\n"; 
  }
}
