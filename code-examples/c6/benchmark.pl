#!/usr/bin/perl -w 

use strict; 
use Date::Manip; 
use Benchmark; 

timethese(5000, {'localtime' => \&ltime, date_manip => \&dmanip}); 

sub ltime { 
  my @now = localtime; 
  sprintf("%4d%02d%02d%02d:%02d:%02d", 
	  $now[5] + 1900, ++$now[4], $now[3], $now[2], $now[1], $now[0]); 
} 

sub dmanip { 
  ParseDate('now'); 
}
