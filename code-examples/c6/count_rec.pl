open FILE, 'input.txt' or die "Can't open input file: $!\n"; 

while (<FILE>) { 
  # do stuff 
} 

print "$. records processed.\n"; 

close FILE;
