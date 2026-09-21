#!/usr/bin/perl 

use strict;
use warnings;
use v5.36;

my @CDs;

sub input { 
  my @attrs = qw(artist title label year); 
  while (<STDIN>) { 
    next unless /-----/ .. /^$/;
    chomp; 
    my %rec; 
    @rec{@attrs} = split /\t/;
    next unless $rec{year};
    push @CDs, \%rec; 
  } 
} 

sub count_cds_by_attr($attr) {
  my %counts;

  foreach (@CDs) { 
    $counts{$_->{$attr}}++;
  } 
  
  return \%counts; 
} 

sub output($counts) {
  foreach (sort keys %$counts) {
    print "$_: $counts->{$_}\n"; 
  } 
} 

my $attr = shift; 

input(); 
my $counts = count_cds_by_attr($attr); 
output($counts); 
