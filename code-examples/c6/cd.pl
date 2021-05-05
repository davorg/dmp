local $/ = "\n%%\n"; 

while (<STDIN>) { 
  chomp; 
  print "Record $. is\n$_"; 
}
