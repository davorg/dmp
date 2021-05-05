$\ = "\n"; 
$, = "\t"; 
print $band, $title, $label, $year;

my @list = qw/This is a list of items/; 
print @list;

@list = qw/This is a list of items/; 
print join(' ', @list);

@list = qw/This is a list of items/; 
print "@list";

my @fields = qw/name title label year/; 

local $" = "\t"; 
local $\ = "\n"; 
foreach (@CDs) { 
  my %CD = %$_; 
  print "@CD{@fields}"; 
}
