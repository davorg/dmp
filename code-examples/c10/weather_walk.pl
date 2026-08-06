use v5.40;
use XML::LibXML;

my $dom = XML::LibXML->load_xml(location => shift);
walk($dom->documentElement, 0);

sub walk ($node, $depth) {
    if ($node->nodeType == XML_ELEMENT_NODE) {
        my $attrs = join ', ',
            map { $_->name . ': ' . $_->value } $node->attributes;
        say '  ' x $depth, $node->nodeName, " [$attrs]";
        walk($_, $depth + 1) for $node->childNodes;
    }
    elsif ($node->nodeType == XML_TEXT_NODE) {
        (my $text = $node->textContent) =~ s/^\s+|\s+$//g;
        say '  ' x $depth, $text if length $text;
    }
}
