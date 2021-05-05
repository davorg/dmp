#!/usr/bin/perl -w 

use strict; 
use Benchmark qw(timethese); 

my $x = 'x' x 100; 

sub using_concat { 
  my $str ='x is ' .$x .' (orthereabouts)'; 
} 

sub using_join { 
  my $str = join '', 'x is ', $x, ' (or thereabouts)'; 
} 

sub using_interp { 
  my $str = "x is $x (or thereabouts)"; 
} 

sub using_sprintf { 
  my $str = sprintf("x is %s (or thereabouts)", $x); 
} 

timethese (1E6, {'concat' => \&using_concat, 
		 'join' => \&using_join, 
		 'interp' => \&using_interp, 
		 'sprintf' => \&using_sprintf, });
