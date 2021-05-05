use Number::Format; 

my $data; 

{ 
  local $/ = undef; 
  $data = <STDIN>; 
} 

my $fmt = Number::Format->new; 

my $num_re = qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/; 

$data =~ s/$num_re/$fmt->format_number($1)/ge; 

print $data;
