use Date::Calc;

my $week = Week_Number($year, 1, 7); 
print Date_to_Text(Monday_of_Week($week, $year));
