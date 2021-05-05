use strict; 

my $users = read_passwd(); 

my @names; 
foreach (keys %{$users}) { 
  next unless $users->{$_}{fullname};

  my ($forename, $surname) = split(/\s+/, $users->{$_}{fullname}, 2); 

  push @names, "$surname, $forename"; 
} 

print map { "$_\n" } sort @names;
