use v5.36;

package Customer;

use Moo;
use Carp;

# Attributes for customer
has 'cust_no'     => (
  is => 'rw',
  lazy => 1,
  default => sub { shift->get_next_cust_no }
);
has 'name'        => (is => 'rw');
has 'address'     => (is => 'rw');
has 'salesperson' => (is => 'rw');

# Constructor with support for id lookup
around BUILDARGS => sub ($orig, $class, %args) {

  if (exists $args{id}) {
    # If an id is passed, populate the object from the database
    my $cust_data = $class->fetch_from_db($args{id});
    if ($cust_data) {
      return $cust_data;  # Return the hash reference with populated data
    } else {
      croak "No customer found with id $args{id}";
    }
  }

  # Call original constructor for other cases
  return $class->$orig(%args);
};

# Fetch customer data based on id (simulating a database fetch)
sub fetch_from_db($class, $id) {
  # Simulate fetching data from a database (replace this with real DB interaction)
  my %fake_db = (
    'CUS-00123' => {
      cust_no => 'CUS-00123',
      name => 'Alice Cooper',
      address => '1234 Elm Street',
      salesperson => 'SP-987',
    },
    'CUS-00124' => {
      cust_no => 'CUS-00124',
      name => 'Bob Marley',
      address => '5678 Maple Avenue',
      salesperson => 'SP-765',
    },
  );

  # Return the customer data if it exists
  return $fake_db{$id} if exists $fake_db{$id};

  return;  # Return undef if no customer found
}

# Validation method
sub validate($self) {
  return $self->is_valid_sales_ref && $self->is_valid_other_attr;
}

# Save method, including validation
sub save($self) {
  unless ($self->validate) {
    croak "Validation failed for customer " . $self->cust_no;
  }

  $self->cust_no($self->get_next_cust_no) unless $self->cust_no;

  return $self->write;
}

# Generate the next customer number
sub get_next_cust_no($self) {
  my $prev_no = 10000;  # Simulate retrieving the last customer number
  $prev_no++;
  return "CUS-$prev_no";
}

# Simulate writing the customer record (to a database, etc.)
sub write($self) {
  print "Customer record for " . $self->name . " (cust_no: " . $self->cust_no . ") saved successfully.\n";
  return 1;
}

# Validation methods (placeholders for more complex logic)
sub is_valid_sales_ref {
  return 1;  # Always return true for simplicity
}

sub is_valid_other_attr {
  return 1;  # Always return true for simplicity
}

1;  # All modules should return a true value
