open FILE, '>out.txt' or die "Can't open out.txt: $!"; 

my $old = select FILE;

foreach (@data) { 
  print; 
} 
select $old;

my $file = select FILE; 
$|=1; 
select $file;

select((select(FILE), $| = 1)[0]);
