foreach (@output_records) { 
  print "$_\n"; 
}

{ 
  local $\ = "\n"; 

  foreach (@output_records) { 
    print; 
  } 
}
