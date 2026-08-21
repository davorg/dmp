use strict;
use warnings;
use utf8;
use Text::Unidecode qw(unidecode);

binmode STDOUT, ':encoding(UTF-8)';

my @artists = ('Björk', 'Sigur Rós', 'Café Tacvba', 'Mötley Crüe');

foreach my $artist (@artists) {
    print unidecode($artist), "\n";
}
