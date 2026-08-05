use HTML::TokeParser; 

use Data::Printer;

my $file = shift;

my $p = HTML::TokeParser->new($file); 
while ($p->get_tag('h1')) { 
  p $p->get_text(); 
}
