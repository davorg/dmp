use Text::CSV_XS; 

my $csv = Text::CSV->new; 
$csv->parse(<STDIN>); 

my @fields = $csv->fields; 

local $" = '|'; 
print "@fields\n";
