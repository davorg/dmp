use strict;
use warnings;
use Path::Tiny;
use Data::Dumper;

my $file = path('cd.txt');
my @attrs = qw(artist title label year);
my @CDs;

for my $line ($file->lines({ chomp => 1 })) {
  my %rec;
  @rec{@attrs} = split /\t/, $line;
  push @CDs, \%rec;
}

print Dumper(\@CDs);
