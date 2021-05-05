my $string = 'Alas poor Yorick. I knew him Horatio.'; 

substr($string, 10, 6) = 'Robert'; 
substr($string, 29) = 'as Bob'; 

print $string;

