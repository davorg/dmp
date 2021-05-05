use Data::Dumper; 
my @CDs; 

my @attrs = qw(artist title label year); 
while (<STDIN>) { 
  chomp; 
  my %rec; @rec{@attrs} = split /\t/; 
  push @CDs, \%rec; 
} 

print Dumper(\@CDs);
