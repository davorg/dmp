use strict; 

use XML::Parser; 

my $p = XML::Parser->new(Style => 'Tree'); 
my $doc = $p->parsefile(shift); 

process_node(@$doc); 

sub process_node { 
  my ($type, $content) = @_; 

  if ($type eq 'OUTLOOK') { 
    print 'Outlook: ', trim($content->[2]), "\n"; 
  } elsif ($type eq 'TEMPERATURE') { 
    my $attrs = $content->[0]; 
    my $temp = trim($content->[2]); 
    print "$attrs->{TYPE}: $temp $attrs->{DEGREES}\n"; 
  } 

  if ($type) { 
    while (my @node = splice @$content, 1, 2) { 
      process_node(@node) 
    } 
  } 
} 

sub trim {
  local $_ = shift; 

  s/\n/ /g; s/^\s+//; 
  s/\s+$//; 
  return $_; 
}
