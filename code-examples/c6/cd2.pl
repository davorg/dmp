local $/ = "\n%%\n"; 

while (<STDIN>) { 
  chomp; 
  print join('|', split(/\n/)), "\n"; 
}
