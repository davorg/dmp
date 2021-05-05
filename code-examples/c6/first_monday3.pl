use Date::Manip;

my $jan_1 = ParseDateString("1 Jan $year"); 
my $mon = Date_GetNext($jan_1, 1, 1); 
print UnixDate($mon, "%d/%m/%Y");
