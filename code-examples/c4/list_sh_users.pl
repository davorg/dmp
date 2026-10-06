use strict;
use warnings;

my $users = read_passwd();

foreach (keys %{$users}) {
  print "$_\n" if $users->{$_}{shell} eq '/bin/sh';
}
