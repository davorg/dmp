use v5.40;
use XML::LibXML;

my $dom = XML::LibXML->load_xml(location => shift);

(my $outlook = $dom->findvalue('/FORECAST/OUTLOOK')) =~ s/^\s+|\s+$//g;
say "Outlook: $outlook";

for my $temp ($dom->findnodes('/FORECAST/TEMPERATURE')) {
    say $temp->getAttribute('TYPE'), ': ', $temp->textContent,
        ' ', $temp->getAttribute('DEGREES');
}
