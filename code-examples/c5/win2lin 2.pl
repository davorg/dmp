my $file; 

{ 
  local $/ = undef;
  $file = <STDIN>; 
} 

$file =~ s/Windows/Linux/g; 
print $file;
