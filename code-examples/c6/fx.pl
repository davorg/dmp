#!/usr/bin/perl -w 

my $target_curr = shift; 
my %rates; 

while (<STDIN>) { 
  chomp; 
  my ($amount, $source_curr, $date) = split(/\t/); 

  $rates{"$source_curr|$target_curr|$date"} ||= get_rate($source_curr, 
							 $target_curr, 
							 $date); 

  $amount *= $rates{"$source_curr|$target_curr|$date"}; 

  print "$amount\t$target_curr\t$date\n"; 
}
