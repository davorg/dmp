use Time::Local; 

# Get the year to work on 
my $year = shift || (localtime)[5] + 1900; 

# Get epoch time of Jan 1st in that year 
my $jan_1 = timelocal(0, 0, 0, 1, 0, $year - 1900); 

# Get day of week for Jan 1 
my $day = (localtime($jan_1))[6]; 

# Monday is day 1 (Sunday is day 0) 
my $monday = 1; 

# Calculate the number of days to the first Monday 
my $diff = (7 - $day + $monday) % 7; 

# Add the correct number of days to $jan_1 
print scalar localtime($jan_1 + (86_400 * $diff));
