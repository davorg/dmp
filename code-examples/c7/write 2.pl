my @strings = qw(Here are a number of strings); 

my $template = 'A6A6A3A8A4A10'; 

print pack($template, @strings), "\n";
