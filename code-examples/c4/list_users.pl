use strict; 
use warnings;
use feature 'say';

my $users = read_passwd(); 

my @names; 
foreach (keys %{$users}) { 
  next unless $users->{$_}{fullname};

  my ($forename, $surname) = split(/\s+/, $users->{$_}{fullname}, 2); 

  push @names, "$surname, $forename"; 
} 

say for sort @names;
