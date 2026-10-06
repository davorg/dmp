#!/usr/bin/perl

use strict;
use warnings;

#!/usr/bin/perl
use strict;
use warnings;
use Benchmark qw(timethese cmpthese);

my  $x = 'x' x 100;

sub using_concat {
  my  $str = 'x is ' .  $x . ' (or thereabouts)';
}

sub using_join {
  my  $str = join '', 'x is ',  $x, ' (or thereabouts)';
}

sub using_interp {
  my  $str = "x is  $x (or thereabouts)";
}

sub using_sprintf {
  my  $str = sprintf("x is %s (or thereabouts)",  $x);
}

my $results = timethese(-3, {
  'concat'  => \&using_concat,
  'join'    => \&using_join,
  'interp'  => \&using_interp,
  'sprintf' => \&using_sprintf,
});

cmpthese($results);
