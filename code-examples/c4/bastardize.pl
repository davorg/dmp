#!/usr/perl/bin/perl 

use strict; 
use warnings;
use feature 'say';
use Text::Bastardize; 

my $text = Text::Bastardize->new; 

print 'Say something: '; 

while (<STDIN>) { 
  chomp; 
  $text->charge($_); 

  foreach my $xfm (qw/rdct pig k3wlt0k rot13 rev censor n20e/) { 
    print "$xfm: "; 
    say eval "\$text->$xfm"; 
  } 
}
