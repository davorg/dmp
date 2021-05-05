#!/usr/bin/perl -w 

use strict; 

my ($input, $output) = @ARGV; 
open(IN, $input) || die "Can t open $input for reading: $!"; 
open(OUT, ">$output") || die "Can t open $output for writing: $!"; 

while (<IN>) { 
  print OUT munge_data($_); 
} 

close(IN) || die "Can't close $input: $!"; 
close(OUT) || die "Can't close $output: $!";
