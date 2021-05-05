use strict; 

use Convert::EBCDIC qw/ascii2ebcdic/; 

my $data;

{ 
  local $/ = undef; 
  $data = <STDIN>; 
} 

print ascii2ebcdic($data);
