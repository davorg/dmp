use strict;
use warnings;
use feature 'say';

my $users = read_passwd();

foreach (keys %{$users}) { 
  say if $users->{$_}{shell} eq '/bin/sh'; 
}
