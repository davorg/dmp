my $fmt = Number::Format->new(INTL_CURRENCY_SYMBOL => 'GBP', 
			      DECIMAL_DIGITS => 1); 

my $number = 1234567.890; 

print $fmt->round($number), "\n"; 
print $fmt->format_number($number), "\n"; 
print $fmt->format_negative($number), "\n"; 
print $fmt->format_picture($number, '###########'), "\n"; 
print $fmt->format_bytes($number), "\n"; 
print $fmt->unformat_number('1,000,000.00'), "\n";
