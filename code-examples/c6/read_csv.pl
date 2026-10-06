use Text::CSV; 

my $csv = Text::CSV->new; 
$csv->parse(<STDIN>); 

my @fields = $csv->fields; 

local $" = '|'; 
print "@fields\n";
