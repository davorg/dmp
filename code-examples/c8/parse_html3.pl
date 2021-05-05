# WARNING: This code works, but only on very simple HTML 
use strict;

while (<STDIN>) { 
  s/<.*?>//g; 
  print; 
}

