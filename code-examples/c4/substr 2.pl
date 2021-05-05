my $string = 'Alas poor Yorick. I knew him Horatio.'; 
my $sub1 = substr($string, 0, 4); # $sub1 contains 'Alas' 
my $sub2 = substr($string, 10, 6); # $sub2 contains 'Yorick' 
my $sub3 = substr($string, 29); # $sub3 contains 'Horatio.' 
my $sub4 = substr($string, -12, 3); # $sub4 contains 'him'
