#!/usr/bin/perl 
use strict; 
use warnings;

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

  open my $trans_fh, '<', $file or die "Can't open $file: $!"; 

  while (defined(my $line = <$trans_fh>)) { 
    chomp $line; 
    my ($english, $american) = split(/\t/, $line); 
    do {$word = $american; last; } if $english eq $word; 
  } 
  return $word; 
}
