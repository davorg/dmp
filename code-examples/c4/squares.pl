foreach (1 .. 12) { 
  s/(\d+)/print "$1 squared is ", $1*$1, "\n"/e; 
}
