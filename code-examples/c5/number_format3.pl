my $de = Number::Format->new(INT_CURR_SYMBOL => 'DEM ',
			     THOUSANDS_SEP => '.', 
			     DECIMAL_POINT => ','); 

my $number = 1234567.890; 

print $de->format_number($number), "\n"; 
print $de->format_negative($number), "\n"; 
print $de->format_price($number), "\n";
