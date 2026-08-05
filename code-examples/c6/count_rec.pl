open my $fh, 'input.txt' or die "Can't open input file: $!\n"; 

while (<$fh>) { 
  # do stuff 
} 

print "$. records processed.\n"; 
