my %rec1 =(txnref => 374, 
	   cust => 'Bloggs & Co', 
	   date => 19991105, 
	   extref => 100103, 
	   dir => '+', 
	   amt => 15000 ); 

my %rec2 =(txnref => 375, 
	   cust => 'Smith Brothers', 
	   date => 19991106, 
	   extref => 1234, 
	   dir => '-', 
	   amt => 4999 ); 

my @cols = ( { name => 'txnref', 
	       width => 5, 
	       num => 1 }, 
	     { name => 'cust',
	       width => 20, 
	       num => 0 }, 
	     { name => 'date', 
	       width => 8, 
	       num => 1 }, 
	     { name => 'extref', 
	       width => 6, 
	       num => 1 }, 
	     { name => 'dir', 
	       width => 1, 
	       num => 0 }, 
	     { name => 'amt', 
	       width => 8, 
	       num =>1 }); 

my $format = build_fmt(\@cols); 

print fixed_rec(\%rec1, \@cols, $format); 
print fixed_rec(\%rec2, \@cols, $format); 

sub build_fmt { 
  my $cols = shift; 

  my $fmt; 
  foreach (@$cols) { 
    if ($_->{num}) { 
      $fmt .= "%0$_->{width}s"; 
    } else { 
      $fmt .= "%-$_->{width}s"; 
    } 
  } 

  return $fmt; 
} 

sub fixed_rec { 
  my ($rec, $cols, $fmt) = @_; 

  my @vals = map { $rec->{$_->{name}} } @$cols; 
  sprintf("$fmt\n", @vals); 
}
