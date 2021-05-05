open FILES 'files.txt' or die "Can't open files.txt: $!"; 

while (<FILES>) { 
  print if m|/davec/|; 
}
