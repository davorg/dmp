use strict; 

use XML::Parser;

my $p = XML::Parser->new(Style => 'Tree'); 

my $doc = $p->parsefile(shift); 

my $level = 0; 
process_node(@$doc); 

sub process_node { 
  my ($type, $content) = @_; 
  my $ind = ' ' x $level; 

  if ($type) { # element 
    my $attrs = shift @$content; 
    print $ind, $type, ' ['; 
    print join(', ', map { "$_: $attrs->{$_}" } keys %{$attrs}); 
    print "]\n"; 

    ++$level; 
    while (my @node = splice(@$content, 0, 2)) { 
      process_node(@node); # Recursively call this subroutine 
    }
    --$level; 
  } else { #text 
    $content =~ s/\n/ /g; 
    $content =~ s/^\s+//; 
    $content =~ s/\s+$//; 
    print $ind, $content, "\n"; 
  } 
}
