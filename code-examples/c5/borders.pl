use strict;
use warnings;

open my $in, '<:encoding(UTF-8)', 'artists.txt'
    or die "Can't open artists.txt: $!";

binmode STDOUT, ':encoding(UTF-8)';

while (my $artist = <$in>) {
    chomp $artist;
    print uc($artist), "\n";
}
