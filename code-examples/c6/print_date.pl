my @months = qw/January February March April May June July August 
                September October November December/; 

my @days = qw/Sunday Monday Tuesday Wednesday Thursday Friday Saturday/; 

my @now = localtime; 
$now[5] += 1900; 

my $date = sprintf '%s %02d %s %4d, %02d:%02d:%02d', 
                   $days[$now[6]], $now[3], $months[$now[4]], 
                   $now[5], $now[2], $now[1], $now[0];
