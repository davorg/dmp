use strict;
use warnings;
use DateTime;

my $perl1 = DateTime->new(year => 1987, month => 12, day => 18);
my $perl5 = DateTime->new(year => 1994, month => 10, day => 17);

my $gap = $perl5->subtract_datetime($perl1);

printf "%d years and %d months passed between Perl 1 and Perl 5\n",
    $gap->years, $gap->months;

# The overloaded '-' operator does the same thing as subtract_datetime.
my $gap2 = $perl5 - $perl1;

printf "%d years and %d months passed between Perl 1 and Perl 5\n",
    $gap2->years, $gap2->months;
