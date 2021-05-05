sub read_passwd {
  my %users;
  my @fields = qw/name pword uid gid fullname home shell/;

  while (<STDIN>) {
    chomp;
    my %rec;
    @rec{@fields} = split(/:/);
    $users{$rec{name}} = \%rec;
  }

  return \%users;
}
