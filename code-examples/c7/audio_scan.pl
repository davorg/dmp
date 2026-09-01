use Audio::Scan;

my $file = shift;

my $data = Audio::Scan->scan($file);

print "Filename: $file\n";
print "MP3 Tags\n";

foreach (sort keys %{ $data->{tags} }) {
  print "$_ : $data->{tags}{$_}\n";
}

print "MP3 Info\n";

foreach (sort keys %{ $data->{info} }) {
  print "$_ : $data->{info}{$_}\n";
}
