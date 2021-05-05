use HTML::TokeParser;

use LWP::Simple;

my $addr = 'http://uk.weather.yahoo.com/1208/index_c.html';

my $page = get $addr;
my $p = HTML::TokeParser->new(\$page) || die "Parse error\n";

$p->get_tag('table') || die "Not enough table tags!" foreach (1 .. 6);

$p->get_tag('font');

my $desc = $p->get_text, "\n";

$p->get_tag('b');
my $high = $p->get_text;
$p->get_tag('b');
my $low = $p->get_text;

print "$desc\nHigh: $high, Low: $low\n";
