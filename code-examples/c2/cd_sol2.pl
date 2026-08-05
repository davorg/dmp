my %years;
while (<STDIN>) {
  next unless /-----/ .. /^$/;
  chomp;
  my ($artist, $title, $label, $year) = split /\t/;

  next unless $year;

  my $rec = {artist => $artist,
	     title => $title,
	     label => $label};
  push @ {$years{$year}}, $rec;
}

foreach my $year (sort keys %years) {
  my $count = $years{$year}->@*;
  print "In $year, $count CDs were released.\n";
  print "They were:\n";
  print map { "* $_->{title} by $_->{artist}\n" } $years{$year}->@*;
}
