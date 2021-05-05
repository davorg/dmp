use strict; 
use XML::DOM; 

my $p = XML::DOM::Parser->new; 
my $doc = $p->parsefile(shift); 

my $level = 0; 
process_node($doc->getFirstChild); 

sub process_node {
  my ($node) = @_; 
  my $ind = ' ' x $level; 
  my $nodeType = $node->getNodeType; 

  if ($nodeType == ELEMENT_NODE) { 
    my $type = $node->getTagName; 
    my $attrs = $node->getAttributes; 

    print $ind, $type, ' ['; 
    my @attrs; 
    foreach (0 .. $attrs->getLength - 1) {
      my $attr = $attrs->item($_);
      push @attrs, $attr->getNodeName . ': ' . $attr->getValue;
    }
    print join (', ', @attrs);
    print "]\n";

    my $nodelist = $node->getChildNodes;
    ++$level;
    for (0 .. $nodelist->getLength - 1) { 
      process_node($nodelist->item($_));
    } --$level; 
  } elsif ($nodeType == TEXT_NODE) { 
    my $content = $node->getData;
    $content =~ s/\n/ /g;
    $content =~ s/^\s+//;
    $content =~ s/\s+$//;
    print $ind, $content, "\n" if $content =~ /\S/; 
  }
}
