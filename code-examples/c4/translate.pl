#!/usr/bin/perl
use strict;
use warnings;
use v5.36;

while (<STDIN>) { 
  s/(\w+)/translate($1)/ge;
  print;
}

my %trans; 
sub translate($word) {
  $trans{lc $word} ||= get_trans(lc $word);
}

sub get_trans($word) {
  my $file = 'american.txt';

  open my $trans_fh, '<', $file or die "Can't open $file: $!"; 

  while (defined(my $line = <$trans_fh>)) { 
    chomp $line; 
    my ($english, $american) = split(/\t/, $line); 
    do {$word = $american; last; } if $english eq $word; 
  } 
  return $word; 
}
