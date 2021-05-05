package Customer_Rules; 

use strict; 
use Carp; 
use vars qw(@EXPORT @ISA); 

@EXPORT = qw(get_next_cust_no save_cust_record); 
@ISA = qw(Exporter); 

require Exporter; 

sub get_next_cust_no { 
  my $prev_cust = get_max_cust_no() 
    || croak "Can't allocate new customer reference.\n"; 

  my ($prev_no) = $prev_cust =~ /(\d+)/; 
  $prev_no++; 

  return "CUS-$prev_no"; 
} 

sub save_cust_record { 
  my $cust = shift; 

  $cust->{cust_no} ||= get_next_cust_no(); 
  is_valid_sales_ref($cust->{salesperson}) 
    || croak "Invalid salesperson ref: $cust->{salesperson}."; 

  write_sales_record($cust); 
}
