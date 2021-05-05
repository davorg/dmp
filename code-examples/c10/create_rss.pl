#!/usr/bin/perl -w 

use strict; 
use XML::RSS; 

my $rss = XML::RSS->new; 

$rss->channel(title => "Dave's News", 
	      link => 'http://daves.news', 
	      language => 'en', 
	      description => "All the news that's unfit to print!", 
	      pubDate => scalar localtime, 
	      managingEditor => 'ed@daves.news', 
	      webMaster => 'webmaster@daves.news'); 

$rss->image(title => "Dave's News", 
	    url => 'http://daves.news/images/logo.gif', 
	    link => 'http://daves.news'); 

$rss->add_item(title=>'Data Munging Book tops best sellers list', 
	       link=>'http://daves.news/cgi-bin/read.pl?id=1'); 

$rss->add_item(title=>'Microsoft abandons ASP for Perl', 
	       link=>'http://daves.news/cgi-bin/read.pl?id=2'); 

$rss->add_item(title=>'Gates offers job to Torvalds', 
	       link=>'http://daves.news/cgi-bin/read.pl?id=3'); 

$rss->save('news.rss');
