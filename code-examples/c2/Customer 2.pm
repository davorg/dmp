package Customer; 

use strict; 

sub new { 
  my $thing = shift; 
  my $self = {}; 

  bless $self, ref($thing) || $thing; 

  $self->init(@_); 
  return $self; 
} 

sub init { 
  my $self = shift; 

  # Extract various interesting things from 
  # @_ and use them to create a data structure 
  # that represents a customer. 
} 

sub validate { 
  my $self = shift; 

  # Call a number of methods, each of which validates 
  # one data item in the customer record. 

  return $self->is_valid_sales_ref 
    && $self->is_valid_other_attr 
      && $self->is_valid_another_attr; 
} 

sub save { 
  my $self = shift; 

  if ($self->validate) { 
    $self->{cust_no} ||= $self->get_next_cust_no; 

    return $self->write; 
  } else { 
    return; 
  } 
} 

# Various other object methods are omitted here, for example 
# code to retrieve a customer object from the database or 
# write a customer object to the database. 

1; # Because all modules should return a true value.
