#!/usr/bin/perl 

use strict; 
use warnings;

my ($input, $output) = @ARGV; 
open(my $in_fh, '<', $input) || die "Can t open $input for reading: $!"; 
open(my $out_fh, '>', $output) || die "Can t open $output for writing: $!"; 

while (<$in_fh>) { 
  print $out_fh munge_data($_); 
} 

