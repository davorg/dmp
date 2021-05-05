my @days = qw/Sunday Monday Tuesday Wednesday Thursday Friday Saturday/; 

my @months = qw/January February March April May June July August 
                September October November December/; 

my $when = 6; # Saturday is day 6 in the week. 
              # You can change this line to get other days of the week. 

my $now = time; 
my @now = localtime($now); 

# This is the tricky bit. 
# $diff will be the number of days since last Saturday. 
# $when is the day of the week that we want.
# $now[6] is the current day of the week. 
# We take the result modulus 7 to ensure that it stays in the 
# range 0 -6. 

my $diff = ($now[6] - $when + 7) % 7; 
my $then = $now - (24 * 60 * 60 * $diff); 
my @then = localtime($then); 
$then[5] += 1900; 
print "$days[$then[6]] $then[3] $months[$then[4]] $then[5]";
