use v5.36;
use Customer;

# Create a new customer object
my $cust = Customer->new(
  name       => prompt_user('Enter new customer name: '),
  address    => prompt_user('Enter customer address: '),
  salesperson => prompt_user('Enter salesperson code: ')
);

# Attempt to save the customer object
if ($cust->save) {
  print "New customer saved successfully.\n";
  print "New customer code is ", $cust->cust_no, "\n";
} else {
  print "Error saving new customer.\n";
}

# A simple subroutine to prompt the user and capture input
sub prompt_user($prompt) {
  print $prompt;
  my $input = <STDIN>;
  chomp($input);
  return $input;
}
