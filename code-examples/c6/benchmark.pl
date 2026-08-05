#!/usr/bin/perl

use strict;
use warnings;

use Time::Piece;
use Benchmark;

timethese(100_000, {'localtime' => \&ltime, time_piece => \&time_piece});

sub ltime {
  my @now = localtime;
  sprintf("%4d%02d%02d%02d:%02d:%02d",
          $now[5] + 1900, ++$now[4], $now[3], $now[2], $now[1], $now[0]);
}

sub time_piece {
  localtime->strftime('%Y%m%d:%H:%S');
}
