binmode STDIN; 

my $data; 

read(STDIN, $data, 8); 

die "Not a PNG file" unless $data eq "\x89PNG\cM\cJ\cZ\cM"; 

while (read(STDIN, $data, 8)) { 
  my ($size, $type) = unpack('Na4', $data); 

  print "$type ($size bytes)\n"; 

  read(STDIN, $data, $size); 

  if ($type eq 'IHDR') { 
    my ($w, $h, $bitdepth, $coltype, $comptype, $filtype, $interlscheme) 
      = unpack('NNCCCCC', $data); 

    print << "END"; 
  Width: $w, Height: $h 
  Bit Depth: $bitdepth, Color Type: $coltype 
  Compression Type: $comptype, Filtering Type: $filtype 
  Interlace Scheme: $interlscheme 
END 
  } 

  read(STDIN, $data, 4); 
}
