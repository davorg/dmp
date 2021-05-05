open MAIL, 'mail.txt' or die "Can't open mail.txt: $!"; 

while (<MAIL>) { 
  if (/^([^:]+): ?(.+)$/) { 
    print "Header $1 has the value $2\n"; 
}
