use strict; 
use warnings;
use feature 'class';
no warnings 'experimental::class';

class Customer; 

field $name :param;
field $address :param;
field $cust_no :param;
field $sales_person :param;

method validate { 
  my $self = shift; 

  # Call a number of methods, each of which validates 
  # one data item in the customer record. 

  return $self->is_valid_sales_ref 
    && $self->is_valid_other_attr 
    && $self->is_valid_another_attr; 
} 

method save { 
  my $self = shift; 

  if ($self->validate) { 
    $cust_no //= $self->get_next_cust_no; 

    return $self->write; 
  } else { 
    return; 
  } 
} 

# Various other object methods are omitted here, for example 
# code to retrieve a customer object from the database or 
# write a customer object to the database. 

1; # Because all modules should return a true value.
