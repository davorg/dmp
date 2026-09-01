use Audio::Scan;

my $file = shift;

my $data = Audio::Scan->scan($file);

print "Filename: $file\n";
print "MP3 Tags\n";

foreach (sort keys %{ $data->{tags} }) {
  print "$_ : ", format_value($data->{tags}{$_}), "\n";
}

print "MP3 Info\n";

foreach (sort keys %{ $data->{info} }) {
  print "$_ : ", format_value($data->{info}{$_}), "\n";
}

sub format_value {
  my ($value) = @_;
  return $value unless ref $value eq 'ARRAY';

  # Some array-valued tags (embedded artwork, Xing seek tables) carry
  # large binary blobs that aren't useful to print as text. This is a
  # generic heuristic, not real per-tag understanding - see the book
  # text for where it falls down.
  return join(', ', map {
      !defined $_     ? ''
    : length($_) > 60 ? sprintf('<%d bytes of binary data>', length($_))
    :                   $_
  } @$value);
}
