open my $files_fh, 'files.txt' or die "Can't open files.txt: $!"; 

while (<$files_fh>) { 
  print if m|/davec/|; 
}
