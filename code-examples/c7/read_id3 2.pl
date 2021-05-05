use MPEG::MP3Info; 

my $file = shift; 
my $tag = get_mp3tag($file); 
my $info = get_mp3info($file); 

print "Filename: $file\n"; 
print "MP3 Tags\n"; 

foreach (sort keys %$tag) { 
  print "$_ : $tag->{$_}\n"; 
} 

print "MP3 Info\n"; 

foreach (sort keys %$info) { 
  print "$_ : $info->{$_}\n"; 
}
