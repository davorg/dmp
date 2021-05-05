my $string = 'To be or not to be.'; 
my $pos1 = index($string, 'be'); # $pos1 is 3 
my $pos2 = rindex($string, 'be'); # $pos2 is 16 
my $pos3 = index($string, 'be', 5); # $pos3 is 16 
my $pos4 = index($string, 'not'); # $pos4 is 9 
my $pos5 = rindex($string, 'not'); # $pos5 is 9
