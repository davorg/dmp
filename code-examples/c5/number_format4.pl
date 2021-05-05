my $fmt = Number::Format->new(NEG_FORMAT=> '(x)'); 

my $debt = -12345678.90; 

print $fmt->format_negative($debt);
