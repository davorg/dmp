use HTML::TokeParser; 

my $file = shift;

my $p = HTML::TokeParser->new($file); 

my $tag; 
while ($tag = $p->get_tag()) { 
  next unless $tag->[0] =~ /^h(\d)/; 
  my $level = $1; 
  print ' ' x$level, "Head $level: ", $p->get_text(), "\n"; 
}
