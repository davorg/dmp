use v5.40;
use XML::LibXML;

my $dom = XML::LibXML->load_xml(location => shift);

(my $outlook = $dom->findvalue('/forecast/outlook')) =~ s/^\s+|\s+$//g;
say "Outlook: $outlook";

for my $temp ($dom->findnodes('/forecast/temperature')) {
    say $temp->getAttribute('type'), ': ', $temp->textContent,
        ' ', $temp->getAttribute('degrees');
}
