use v5.40;
use XML::LibXML;
use JSON::MaybeXS;
use YAML::PP;

my $dom = XML::LibXML->load_xml(location => 'cds.xml');

my @cds = map {
    {
        artist   => $_->getAttribute('artist'),
        title    => $_->getAttribute('title'),
        label    => $_->getAttribute('label'),
        released => $_->getAttribute('released'),
        tracks   => [ map { $_->textContent } $_->findnodes('./track') ],
    }
} $dom->findnodes('/cds/cd');

say JSON->new->utf8->pretty->encode(\@cds);
say YAML::PP->new->dump_string(\@cds);
