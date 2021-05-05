my $record = <STDIN>; 
chomp $record; 
my %cd; ($cd{artist}, $cd{title}, $cd{label}, $cd{year}) 
  = split (/\t/, $record);
