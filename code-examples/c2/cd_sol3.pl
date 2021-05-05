my @CDs; 

sub input { 
  my @attrs = qw(artist title label year); 
  while (<STDIN>) { 
    chomp; 
    my %rec; @rec{@attrs} = split /\t/; 
    push @CDs, \%rec; } 
}

sub count_cds_by_year { 
  my %years; 
  foreach (@CDs) { 
    $years{$_->{year}}++; 
  } 
  return \%years; 
}

sub count_cds_by_artist { 
  my %artists; 
  foreach (@CDs) { 
    $artists{$_->{artist}}++; 
  } 
  return \%artists; 
}
