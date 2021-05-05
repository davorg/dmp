#!/usr/bin/perl -w 

use strict; 
use HTML::TreeBuilder; 

my $h = HTML::TreeBuilder->new; 

$h->parse_file(shift); 

$h->dump; 

print $h->as_HTML;

