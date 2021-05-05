use Text::CSV; 

sub read_csv { 
  my $csv = Text::CSV->new; 
  my @data; 

  while (<STDIN>) { 
    $csv->parse($_); 
    push @data, [$csv->fields]; 
  } 

  return \@data; 
} 

sub write_csv { 
  my $data = shift; 
  my $csv = Text::CSV->new; 

  foreach (@$data) { 
    $csv->combine(@$_); 
    print $csv->string; 
  } 
}

my $data = read_csv; 
foreach (@$data) { 
  # Do something to each record. 
  # Individual fields are accessed as 
  # $_->[0], $_->[1], etc ...
} 

write_csv($data);
