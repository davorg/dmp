my $line = <STDIN>; # The metadata line 

chomp $line; 

my $mark = '|'; # The field marker 

my @fields = split($mark, $line); 

my @widths = map { length($_)+1 } @fields; 

my $fmt = join('', map { "A$_" } @widths); 

while (<STDIN>) { 
  chomp; 

  my @data = unpack($fmt, $_); 

  # Do something useful with the fields in @data 
}
