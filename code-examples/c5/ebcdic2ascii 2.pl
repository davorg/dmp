use strict; 

use Convert::EBCDIC; 

my $data; my $conv = Convert::EBCDIC->new; 

my $data; 

{ 
  local $/ = undef; 
  $data = <STDIN>; 
} 

print $conv->toascii($data);
