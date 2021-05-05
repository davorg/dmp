use Time::Local; 

my @now = localtime; # Get the current date and time 

my @then = (0, 0, 12, @now[3 .. 5]); # Normalize time to 12 noon 

my $then = timelocal(@then); # Convert to number of seconds 

$then += $x * 86_400; # Where $x is the number of days to add 

@then = localtime($then); # Convert back to array of values 

@then[0 .. 2] = @now[0 .. 2]; # Replace 12 noon with real time 

$then = timelocal(@then); # Convert back to number of seconds 

print scalar localtime $then; # Print result
