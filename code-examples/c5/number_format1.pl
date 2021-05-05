my $fmt = Number::Format->new; # use all defaults 

my $number = 1234567.890;

print $fmt->round($number), "\n"; 
print $fmt->format_number($number), "\n"; 
print $fmt->format_negative($number), "\n"; 
print $fmt->format_picture($number, '###########'), "\n"; 
print $fmt->format_price($number), "\n"; 
print $fmt->format_bytes($number), "\n"; 
print $fmt->unformat_number('1,000,000.00'), "\n";
