my @new_cols = ('Cross, Dave', '07/09/1962', 'M', 
		'Field with "embedded" quotes'); 

$csv->combine(@new_cols); 

print $csv->string;
