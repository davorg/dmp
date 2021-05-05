#!/usr/local/bin/perl -w 

use strict; 

(@ARGV == 2) or die "Error: source and target formats not given."; 

my ($src, $tgt) = @ARGV; 
my %conv = (CR => "\cM", 
	    LF => "\cJ", 
	    CRLF => "\cM\cJ"); 

$src = $conv{$src}; 
$tgt = $conv{$tgt}; 

$/ = $src; 
while (<STDIN>) {
  s/$src/$tgt/go; print; 
}
