@out = sort @in;

@out = sort numerically @in; 

sub numerically { 
  return $a <=> $b; 
}

sub desc_numerically { 
  return $b <=> $a; 
}

sub lexically { 
  return $a cmp $b; 
}
