use Customer; 

print 'Enter new customer name: '; 
my $name = <STDIN>; 

print 'Enter customer address: '; 
my $addr = <STDIN>; 

print 'Enter salesperson code: '; 
my $sp_code = <STDIN>; 

# Write code similar to that above to get any other 
# required data from the user. 

my $cust = Customer->new(
  name => $name,
  address => $addr,
  sales_person => $sp_code
);

if ($cust->save) { 
  print "New customer saved successfully.\n"; 
  print "New customer code is ", $cust->code, "\n"; 
} else { 
  print "Error saving new customer.\n"; 
}
