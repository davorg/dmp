my %key_cache; 

my @out = sort orcish @in; 

sub orcish { 
  return ($key_cache{$a} ||= get_sort_key($a)) 
    <=> ($key_cache{$b} ||= get_sort_key($b)); 
} 

sub get_sort_key { 
  # Code that takes the list element and returns 
  # the part that you want to sort on 
}
