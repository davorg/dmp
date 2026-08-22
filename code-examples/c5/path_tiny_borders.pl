use strict;
use warnings;
use Path::Tiny;

binmode STDOUT, ':encoding(UTF-8)';

my @artists = path('artists.txt')->lines_utf8({ chomp => 1 });

print uc($_), "\n" for @artists;
