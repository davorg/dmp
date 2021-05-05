use strict; 
use XML::RSS; 

my $rss = XML::RSS->new; 

$rss->parsefile(shift); 

print $rss->channel('title'), "\n"; 
print $rss->channel('description'), "\n"; 
print $rss->channel('link'), "\n"; 
print 'Published: ', $rss->channel('pubDate'), "\n"; 
print 'Editor: ', $rss->channel('managingEditor'), "\n\n"; 
print "Items:\n"; 

foreach (@{$rss->items}) { 
  print $_->{title}, "\n\t<", $_->{link}, ">\n"; 
}
