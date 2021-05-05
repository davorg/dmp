my %years;
while (<STDIN>) {
  chomp;
  my ($artist, $title, $label, $year) = split /\t/;

  my $rec = {artist => $artist,
	     title => $title,
	     label => $label};
  push @ {$years{$year}}, $rec;
}

foreach my $year (sort keys %years) {
  my $count = scalar @{$years{$year}};
  print "In $year, $count CDs were released.\n";
  print "They were:\n";
  print map { "$_->{title} by $_->{artist}\n" } @{$years{$year}};
}
