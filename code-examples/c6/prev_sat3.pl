use Date::Manip;

my $today = ParseDateString('today'); 
my $sat = Date_GetPrev($today, 6, 0); 
print UnixDate($sat, "%d/%m/%Y");
