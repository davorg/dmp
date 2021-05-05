#!/usr/bin/perl -w 

use Memoize; 

memoize 'get_rate'; 

my $target_curr = shift; 

while (<STDIN>) { 
  chomp;
  my ($amount, $source_curr, $date) = split(/\t/); 

  $amount *= get_rate($source_curr, $target_curr, $date); 

  print "$amount\t$target_curr\t$date\n"; 
}
