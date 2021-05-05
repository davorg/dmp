use HTML::TokeParser; 

my $file = shift;

my $p = HTML::TokeParser->new($file); 
while ($p->get_tag('h1')) { 
  print $p->get_text(), "\n"; 
}
