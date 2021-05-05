use HTML::Parser; 

use LWP::Simple; 

sub start { 
  my ($tag, $attr, $attrseq) = @_; 
  print "Found $tag\n"; 
  foreach (@$attrseq) { 
    print " [$_ -> $attr->{$_}]\n"; 
  } 
} 

my $h = HTML::Parser->new(start_h => [\&start, 'tagname,attr,attrseq']); 
my $page = get(shift); 
$h->parse($page);
