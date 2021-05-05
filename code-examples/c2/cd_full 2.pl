#!/usr/bin/perl -w 

use strict; 

my @CDs; 

sub input { 
  my @attrs = qw(artist title label year); 
  while (<STDIN>) { 
    chomp; 
    my %rec; 
    @rec{@attrs} = split /\t/; 
    push @CDs, \%rec; 
  } 
} 

sub count_cds_by_attr { 
  my $attr = shift; 

  my %counts; 

  foreach (@CDs) { 
    $counts{$_->{$attr}}++;
  } 
  
  return \%counts; 
} 

sub output { 
  my $counts = shift; 
  foreach (sort keys %{$counts}) { 
    print "$_: $counts->{$_}\n"; 
  } 
} 

my $attr = shift; 

input(); 
my $counts = count_cds_by_attr($attr); 
output($counts);
