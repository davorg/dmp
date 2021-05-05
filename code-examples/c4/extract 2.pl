my $string = 'Text with an [important bit] in brackets'; 

my $start = index($string, '['); 
my $end = rindex($string, ']'); 

my $keep = substr($string, $start+1, $end-$start-1);
