use v5.36;
use Test2::V0;

# The same structure as before, but with two deliberate mistakes:
# the wrong label, and a missing year.
my $cd = { artist => 'Bowie, David', title => 'Blackstar', label => 'EMI' };

is($cd,
   { artist => 'Bowie, David', title => 'Blackstar',
     label  => 'Columbia',     year  => 2016 },
   'a CD line is parsed into the right hash');

done_testing();
