#!/usr/bin/perl -w 
use strict; 

while (<STDIN>) { 
  s/(\w+)/translate($1)/ge;
  print;
}

my %trans; 
sub translate { 
  my $word = shift; 
  
  $trans{lc $word} ||= get_trans(lc $word); 
}

sub get_trans { 
  my $word = shift;
  
  my $file = 'american.txt'; 

  open(TRANS, $file) || die "Can't open $file: $!"; 

  my ($line, $english, $american);
  while (defined($line = <TRANS>)) { 
    chomp $line; 
    ($english, $american) = split(/\t/, $line); 
    do {$word = $american; last; } if $english eq $word; 
  } 
  close TRANS; 
  return $word; 
}
