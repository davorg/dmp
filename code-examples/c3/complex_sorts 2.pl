@out = sort { $a <=> $b } @in; 
@out = sort { $b <=> $a } @in; # or @out = reverse sort { $a <=> $b } @in 
@out = sort { $a cmp $b } @in;

my @out = sort namesort @in; 

sub namesort { 
  return $a->{surname} cmp $b->{surname} 
  || $a->{forename} cmp $b->{forename}; 
}

my @out = sort namesort @in; 

sub namesort { 
  return $a->{surname} cmp $b->{surname} 
  || $a->{forename} cmp $b->{forename} 
  || $b->{age} <=> $a->{age}; 
}
