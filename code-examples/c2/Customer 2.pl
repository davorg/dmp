use Customer; 

my $cust = Customer->new; 

print 'Enter new customer name: '; 
my $name = <STDIN>; 
$cust->name($name); 

print 'Enter customer address: '; 
my $addr = <STDIN>; 
$cust->address($addr); 

print 'Enter salesperson code: '; 
my $sp_code = <STDIN>; 
$cust->salesperson($sp_code); 

# Write code similar to that above to get any other 
# required data from the user. 

if ($cust->save) { 
  print "New customer saved successfully.\n"; 
  print "New customer code is ", $cust->code, "\n"; 
} else { 
  print "Error saving new customer.\n"; 
}
