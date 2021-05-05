use POSIX qw(strftime); 

foreach ('%c', '%A %d %B %Y', 'Day %j', '%I:%M:%S%p (%Z)') { 
  print strftime($_, localtime), "\n"; 
}
