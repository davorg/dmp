use strict; 

use XML::Parser; 
my $p = XML::Parser->new(Style => 'Objects'); 

my $doc = $p->parsefile(shift); 

my $level = 0; 
process_node($doc->[0]); 

sub process_node { 
  my ($node) = @_; 
  my $ind = ' ' x $level; 
  my $type = ref $node; 
  $type =~ s/^.*:://; 

  if ($type ne 'Characters') { 
    my $attrs = {%$node}; 
    delete $attrs->{Kids}; 
    print $ind, $type, ' ['; 
    print join(', ', map { "$_: $attrs->{$_}" } keys %{$attrs}); 
    print "]\n"; 

    ++$level; 
    foreach my $node (@{$node->{Kids}}) { 
      process_node($node); 
    } 
    --$level; 
  } else { 
    my $content = $node->{Text}; 
    $content =~ s/\n/ /g; 
    $content =~ s/^\s+//; 
    $content =~ s/\s+$//; 
    print $ind, $content, "\n" if $content =~ /\S/; 
  } 
}
