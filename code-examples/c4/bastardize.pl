#!/usr/bin/perl

use strict;
use warnings;

#!/usr/bin/perl
use strict;
use warnings;

use Text::Bastardize;

my $text = Text::Bastardize->new;
print 'Say something: ';
while (<STDIN>) {
  chomp;
  $text->charge($_);
  foreach my $xfm (qw/rdct pig k3wlt0k rot13 rev censor n20e/) {
    print "$xfm: ";
    print eval "\$text->$xfm";
    print "\n";
  }
}
