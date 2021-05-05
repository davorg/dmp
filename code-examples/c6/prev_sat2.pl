use Date::Calc;

my ($year, $month, $day) = Today; 
my $week = Week_Number($year, $month, $day); 
print Date_to_Text(Add_Delta_Days(Monday_of_Week($week, $year), -2));
