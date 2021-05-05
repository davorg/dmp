my $line = <STDIN>; # The metadata line 

my $width = 3; # The width of each number in $line; 

my $fields = length($line) / $width; 

my $meta_fmt = 'a3' x $fields; 

my @widths = unpack($meta_fmt, $line);

my $fmt = join('', map { "A$_" } @widths); 

while (<STDIN>) { 
  my @data = unpack($fmt, $_); 

  # Do something useful with the fields in @data 
}
