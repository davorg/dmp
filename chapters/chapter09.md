Chapter 9: HTML
===============

What this chapter covers:

*  Getting data from the Internet

*  Parsing HTML

*  Prebuilt HTML parsers

*  Why scraping is fragile (a cautionary tale)

*  Web::Query, a modern jQuery-style alternative for scraping

Since the explosion in interest in the World Wide Web in the 1990s,
HTML has become one of the most popular file formats that we can use
for the purpose of extracting data. At the end of the 1990s it seemed
more and more likely that HTML would be overtaken in terms of
popularity by its younger cousin, XML.

In this chapter we will look at HTML and see how to extract the data
that we  need from HTML documents.

Extracting HTML data from the World Wide Web
--------------------------------------------

Perl has a set of modules which can be used to read data from the
World Wide Web. This set of modules is called LWP (for Library for WWW
Programming in Perl) and you can find it on the CPAN under the name
[libwww](https://metacpan.org/pod/LWP). LWP contains modules for
gleaning data from the WWW under a large number of conditions. Here we
will look at only the simplest module that it contains. If these
methods don’t work for you then you should take a close look at the
documentation that comes with LWP.

The simplest method to use when pulling data down from the web is the
[LWP::Simple](https://metacpan.org/pod/LWP::Simple) module. This
module exports a number of functions which can send an HTTP request
and handle the response. The simplest of these is the get function.
This function takes a URL as an argument and returns the data that is
returned when that URL is requested. For example:

<!-- listing: c9/get.pl fragment -->

	use LWP::Simple;

	my $page = get('http://example.com/');

will put the contents of the requested page into the variable `$page`.
If there is an error, then get will return `undef`.

Two of the most common steps that you will want to take with the data
returned will be to print it out or to store it in a file.
[LWP::Simple](https://metacpan.org/pod/LWP::Simple) has functions that
carry out both of these options with a single call:

	getprint('http://example.com/');

will print the page directly to `STDOUT` and

	getstore('http://example.com/', 'example.html');

will store the data in the (local) file example.html.

A word about HTTPS. These examples use plain `http` URLs, but almost
every site you'll want to fetch today insists on `https`. LWP can't
do that on its own: HTTPS support was split out of libwww-perl (in
version 6.02) into a separate module,
[LWP::Protocol::https](https://metacpan.org/pod/LWP::Protocol::https).
Install it and *every* LWP module, `LWP::Simple` and `LWP::UserAgent`
included, can fetch `https` URLs with no changes to your code. It
also pulls in the SSL libraries and certificate bundle that HTTPS
needs.

`LWP::Simple` is also deliberately minimal: `get` just returns
`undef` if anything goes wrong, with no status code, no response
headers, and no say over timeouts. When you need those, reach for
`LWP::UserAgent` (from the same LWP bundle), or for
[HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny), a small HTTP client
that has shipped with Perl itself since 5.14. It's what we'll use for
API calls in [Chapter 10](ch015.xhtml). Like LWP, it needs
`IO::Socket::SSL` and `Net::SSLeay` installed before it will talk
HTTPS.

Parsing HTML
------------

Parsing HTML in Perl is all based around the
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) CPAN module.
This module takes either an HTML file or a chunk of HTML in a variable
and splits it into individual tokens. To use
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) we need to
define a number of *handler* subroutines which are called by the
parser whenever it encounters certain constructions in the document
being parsed.

The HTML that you want to parse can be passed to the parser in a
couple of  ways. If you have it in a file you can use the `parse_file`
method, and if you have it in a variable you can use the parse method.

Note that what I am describing here is
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) version 3. In
this version, the module was rewritten  so that it was implemented in
C for increased performance. The interface was also changed.
Unfortunately, the version available for ActivePerl on Win32 platforms
still seems to be the older, pure Perl version, which doesn’t support
the new interface.

### Example: simple HTML parsing

Here is a very simple HTML parser that displays all of the HTML tags
and attributes it finds in an HTML page.

<!-- listing: c9/html_parser.pl -->

	use HTML::Parser;
	use LWP::Simple;

	sub start($tag, $attr, $attrseq) {
	  print "Found $tag\n";
	  foreach (@$attrseq) {
	    print " [$_ -> $attr->{$_}]\n";
	  }
	}
	my $h = HTML::Parser->new(
	  start_h => [\&start,'tagname,attr,attrseq']);
	my $page = get(shift);
	$h->parse($page);

In this example, we define one handler, which is called whenever the
parser encounters the start of an HTML tag. The subroutine start is
defined as being a handler as part of the `HTML::Parser->new` call.
Notice that we pass new a hash of values. The keys to the hash are the
names of the handlers and the values are references to arrays that
define the associated subroutines. The first element of the referenced
array is a reference to the handler subroutine and the second element
is a string that defines the parameters that the subroutine expects.
In this case we require the name of the tag, a hash of the tag’s
attributes, and an array which contains the sequence in which the
attributes were originally defined. All parameters are passed to the
handler as scalars. This means that the attribute hash and the
attribute sequence array are actually passed as references.

In the start subroutine, we simply print out the type of the HTML
element that  we have found, together with a list of its attributes.
We use the `@$attrseq` array to display the attributes following the
same order in which they were defined in the original HTML. Had we
relied on keys `%$attr`, we couldn’t have guaranteed the attributes
appearing in any particular order.

#### Testing the simple HTML parser

In order to test this, here is a simple HTML file:

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
	<html>
	<head><title>Test HTML Page</title></head>
	<body bgcolor="#FFDDDD">
	<h1 ALIGN=center>test HTML Page</h1>
	<p>This is the first paragraph</p>
	<p><font color="#0000FF">This</font> is the 2nd paragraph</p>
	<p>Here is a list</p>
	<ol><li>Item one</li>
	<li>Item two</li></ul>
	</body>
	</html>

and here is the output we get from running it through our parser:

	Found html
	Found head
	Found title
	Found body
	[bgcolor -> #FFDDDD]
	Found h1
	[align -> center]
	Found p
	Found p
	Found font
	[color -> #0000FF]
	Found p
	Found ol
	Found li
	Found li

Each time the parser finds an HTML element, it calls `start`, which
displays information about the element and its attributes. Notice that
none of the actual text of the document appears in our output. For
that to happen we would need to define a text handler. You would do
that by declaring a `text_h` key/value pair in the call to
`HTML::Parser->new`. You would define the handler in the same way, but
in this case you might choose a different set of parameters. Depending
on what your script was doing, you would probably choose the `text` or
`dtext` parameters. Both of these parameters give you the text found,
but in the dtext version any HTML entities are decoded.

You can see how easy it is to build up a good idea of the structure of
the document. If you wanted a better picture of the structure of the
document, you could also define an end handler and display information
about closing tags as well. One option might be to keep a global
variable, which was incremented each time a start tag was found, and
decremented each time a close tag was found. You could then use this
value to indent the data displayed according to how deeply nested the
element was.

Prebuilt HTML parsers
---------------------

[HTML::Parser](https://metacpan.org/pod/HTML::Parser) gives you a
great deal of flexibility to parse HTML files in any way that you
want. There are, however, a number of tasks that are common enough
that someone has already written an
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) subclass to
carry them out.

### HTML::LinkExtor


One of the most popular is
[HTML::LinkExtor](https://metacpan.org/pod/HTML::LinkExtor) which is
used to produce a list of all of the links in an HTML document. There
are two ways to use this module. The simpler way is to parse the
document and then run the links function, which returns an array of
the links found. Each of the elements in this array is a reference to
another array. The first element of this second-level array is the
type of element in which the link is found. The subsequent elements
occur in pairs. The first element in a pair is the name of an
attribute which denotes a link, and the second is the value of that
attribute. This should become a bit clearer with an example.

#### Example: listing links with HTML::LinkExtor

Here is a program which simply lists all of the links found in an
HTML file.

<!-- listing: c9/linkextor.pl -->

	use HTML::LinkExtor;

	my $file = shift;
	my $p = HTML::LinkExtor->new;
	$p->parse_file($file);
	my @links = $p->links;
	foreach (@links) {
	  print 'Type: ', shift @$_, "\n";
	  while (my ($name, $val) = splice(@$_, 0, 2)) {
	    print "$name -> $val\n";
	  }
	}

and here is a sample HTML file which contains a number of links of
various kinds:

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
	<html>
	<head><title>Test HTML Page</title>
	<link rel=stylesheet type='text/css' href='style.css'></head>
	<body background="back.gif">
	<h1 ALIGN=center>test HTML Page</h1>
	<p>This is the first paragraph.
	It contains a <a href="http://www.perl.com/">link</a></p>
	<p><font color="#0000FF">This</font> is the 2nd paragraph.
	It contains an image - <img src="test.gif"></p>
	<p>Here is an image used as a link<br>
	<a href="http://www.pm.org"><img src="pm.gif"
	lowsrc="pmsmall.gif"></a></p>
	</body>
	</html>

When we run this program on this HTML file, the output is as follows:

	Type: link
	href -> style.css
	Type: body
	background -> back.gif
	Type: a
	href -> http://www.perl.com/
	Type: img
	src -> test.gif
	Type: a
	href -> http://www.pm.org
	Type: img
	src -> pm.gif
	lowsrc -> pmsmall.gif

#### Example: listing specific types of links with HTML::LinkExtor

As you can see, there are a number of different types of links that
[HTML::LinkExtor](https://metacpan.org/pod/HTML::LinkExtor) returns. The complete list changes as the HTML
specification changes, but basically any element that can refer to an
external file is examined during parsing. If you only want to look at,
say, links within an a tag, then you have a couple of options. You can
either parse the file as we’ve just discussed and only use the links
you are interested in when you iterate over the list of links (using
code something like: `next unless $_->[0] eq 'a'`), or you can use
the second, more complex, interface to [HTML::LinkExtor](https://metacpan.org/pod/HTML::LinkExtor). For this
interface, you need to pass the `new` function a reference to a
function which the parser will call each time it encounters a link.
This function will be passed the name of the element containing the
link together with pairs of parameters indicating the names and values
of attributes which contain the actual links. Here is an example which
displays only the a links within a file:

<!-- listing: c9/linkextor2.pl -->

	use HTML::LinkExtor;

	my $file = shift;
	my @links;
	my $p = HTML::LinkExtor->new(\&check);
	$p->parse_file($file);
	foreach (@links) {
	  print 'Type: ', shift @$_, "\n";
	  while (my ($name, $val) = splice(@$_, 0, 2)) {
	    print " $name -> $val\n";
	  }
	}
	sub check(@args) {
	  push @links, [@args] if $args[0] eq 'a';
	}

Running our test HTML file through this program gives us the following
output:

	Type: a
	href -> http://www.perl.com/
	Type: a
	href -> http://www.pm.org

which only lists the links that we are interested in.

### HTML::TokeParser

Another useful prebuilt HTML parser module is
[HTML::TokeParser](https://metacpan.org/pod/HTML::TokeParser). This
parser effectively turns the standard
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) interface on its
head. [HTML::TokeParser](https://metacpan.org/pod/HTML::TokeParser)
parses the file and stores the contents as a stream of tokens. You can
request the next token from the stream using the `get_tag` method.
This method takes an optional parameter which is a tag name. If this
argument is used then the parser will skip tags until it reaches a tag
of the given type. There is also a get `_text` function which returns
the text at the current position in the stream.

#### Example: extracting `<h1>` elements with HTML::TokeParser

For example, to extract all of the `<h1>` elements from an HTML file
you could use code this way:

	use HTML::TokeParser;

	my $file = shift;

	my $p = HTML::TokeParser->new($file);
	while ( $p->get _tag('h1')) {
	  print $p->get _text(), "\n";
	}

We will use the following HTML file to test this program:

	<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
	<html>
	<head><title>Test HTML Page</title>
	</head>
	<body>
	<h1>The first major item</h1>
	<h2>Section 1.1</h2>
	<p>Some text<p>
	<h2>Section 1.2</h2>
	<h3>Section 1.2.1</h3>
	<p>blah</p>
	<h3>Section 1.2.2</h3>
	<p>blah</p>
	<h1>Another major header</h1>
	<h2>Section 2.1</h2>
	<h3>Section 2.1.1</h3>
	<h3>Section 2.1.2</h3>
	<h2>Section 2.2</h2>
	</body>
	</html>

and here is the output:

	The first major item
	Another major header

#### Example: listing all header tags with HTML::TokeParser

A more sophisticated approach might be to look at the structure of the
document by examining all of the headers in the document. In this case
we need to look a little more closely at the return value from
`get_tag`. This is a reference to an array, the elements of which are
different for start tags and close tags. For start tags the elements
are: the tag name, a reference to a hash containing attribute names
and values, a reference to an array indicating the original order of
the attributes, and the original HTML text. For an end tag the array
contains the name of the tag prefixed with the character `/` and the
original HTML text. We can therefore iterate over all of the tags in a
document, checking them to see which ones are headers and displaying
the structure of the document using code like this:

<!-- listing: c9/tokeparser2.pl -->

	use HTML::TokeParser;

	my $file = shift;

	my $p = HTML::TokeParser->new($file);
	my $tag;
	while ($tag = $p->get_tag()) {
	  next unless $tag->[0] =~ /^h(\d)/;
	  my $level = $1;
	  print ' ' x $level, "Head $level: ", $p->get_text(), "\n";
	}

Notice that we only process tags where the name matches the regular
expression `/^h(\d)/`. This ensures that we only see HTML header tags.
We put brackets around the d to capture this value in $1. This value
indicates the level of the header we have found and we can use it to
calculate how far to indent the output. Running this program on our
previous sample HTML file gives the following output:

	Head 1: The first major item
	Head 2: Section 1.1
	Head 2: Section 1.2
	Head 3: Section 1.2.1
	Head 3: Section 1.2.2
	Head 1: Another major header
	Head 2: Section 2.1
	Head 3: Section 2.1.1
	Head 3: Section 2.1.2
	Head 2: Section 2.2

which is a very useful outline of the structure of the document.

### HTML::TreeBuilder and HTML::Element

Another very useful subclass of
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) is
[HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder). As
you can probably guess from its name, this class builds a parse tree
that represents an HTML document. Each node in the tree is an
[HTML::Element](https://metacpan.org/pod/HTML::Element) object.

#### Example: parsing HTML with HTML::Treebuilder

Here is a simple script which uses
[HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder) to
parse an HTML document.

<!-- listing: c9/treebuilder.pl -->

	#!/usr/bin/perl
	use strict;
    use warnings;
	use HTML::TreeBuilder;

	my $h = HTML::TreeBuilder->new;
	$h->parse_file(shift);
	$h->dump;
	print $h->as_HTML;

In this example we create a new parser object using the
`HTML::Treebuilder->new` method. We then parse our file using the new
object’s `parse_file` method.

Note that HTML::Treebuilder supports the same parsing interface as
[HTML::Parser](https://metacpan.org/pod/HTML::Parser), so you could
just as easily call $h->parse, passing it a variable containing HTML
to parse.

Unlike some other tree-based parsers, this function doesn’t return a
new tree object, rather the parse tree is built within the parser
object itself.

As the example demonstrates, this class has a couple of ways to
display the parse tree. Both of these are, in fact, inherited from the
[HTML::Element](https://metacpan.org/pod/HTML::Element) class. The
dump method prints a simple representation of the element and its
descendents and the `as\_HTML` method prints the element and its
descendents as HTML. This might seem a little less than useful given
that we have just created the parse tree *from* an HTML file, but
there are at least three reasons why this might be useful. First, a
great many HTML files aren’t strictly valid HTML.
[HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder) does a
good job of parsing invalid HTML and the `as\_HTML` method can then be
used to output valid HTML. Second, the
[HTML::Element](https://metacpan.org/pod/HTML::Element) has a number
of methods for changing the parse tree, so you can alter your page and
then use the as_HTML method to produce the altered page. And third,
the tree can be scanned in ways that would be inconvenient or
impossible with just a token stream.

Notice that I’ve been saying that you can call
[HTML::Element](https://metacpan.org/pod/HTML::Element) methods on an
[HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder)
object. This is because [HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder) inherits from both
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) and
[HTML::Element](https://metacpan.org/pod/HTML::Element). An HTML
document should always start with an `<HTML>` and end with a `</HTML>`
tag and therefore the whole document can be viewed as an HTML element,
with all of the other elements contained within it. It is, therefore,
valid to call [HTML::Element](https://metacpan.org/pod/HTML::Element)
methods on our
[HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder)
object.

Both [HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder)
and [HTML::Element](https://metacpan.org/pod/HTML::Element) are part
of the HTML-Tree bundle of modules which can be found on the CPAN.

A cautionary tale about scraping
--------------------------------

The first edition of this book finished its tour of HTML parsing with a
worked example. It fetched Yahoo!'s U.K. weather page for London and used
HTML::TokeParser to pick the forecast out of it: the outlook was in the first
`<font>` tag after the sixth `<table>` tag, and the high and low temperatures
were in the next two `<b>` tags. It was a good example of how to find the
data you want in a web page, and it worked on the day I wrote it.

It didn't keep working. Over the following years the HTML of that page
changed several times, and each time the forecast moved somewhere else, so
the program needed rewriting. Then, at some point in the last twenty-five
years, the page was removed altogether. There is nothing left for the
program to fetch, so I've taken the example out of this edition rather than
print code that can't possibly run.

That's not bad luck; it's what scraping is like. A web page is written for
people, not for programs, and nobody has promised that its structure will
stay the same. A scraper that relies on "the first `<font>` tag after the
sixth `<table>`" is relying on an accident of the current design, and
designs change. Worse, scrapers often fail quietly, carrying on happily
and returning the wrong data instead of stopping with an error.

So, before you write a scraper, ask whether you need to:

*  **Look for an API.** Many sites that publish data also offer it in a
   form meant for programs, usually JSON, with a documented format and
   some promise that it won't change under you. Weather is a good example.
   [Chapter 10](ch015.xhtml) gets the same London forecast from a weather
   API, in less code than the scraper needed and without any HTML
   archaeology.

*  **Look for a feed or a download.** RSS and Atom feeds, CSV files and
   data dumps are all easier to read, and more stable, than the web pages
   they come from.

If there really is no alternative, then scrape defensively. Check the
site's terms of use and its `robots.txt` first. Anchor your extraction on the
most stable landmarks the page offers, such as `id` attributes, class names
and meaningful element names, rather than on counting tags. Check that
what you've found looks the way you expect, and stop with an error if it
doesn't. Keep a saved copy of the page so that you can test your code
without hitting the site, and expect to come back and fix it.

Web::Query: a modern alternative
---------------------------------

The techniques in this chapter -- HTML::Parser, HTML::LinkExtor,
HTML::TokeParser, HTML::TreeBuilder -- are all still perfectly good
Perl, and understanding them is worth your time even today, because
they show you what's actually happening under the hood: tags, tokens,
a tree of elements. But if you're screen-scraping day to day rather
than learning how parsing works, there's a more direct route:
[Web::Query](https://metacpan.org/pod/Web::Query), which gives you a
jQuery-style interface -- select elements with a CSS selector, then
pull out the text or attributes you want -- built on top of
HTML::TreeBuilder under the hood.

Here's the CD collection again, this time as a fragment of HTML
(`webquery.html`):

	<ul id="collection">
	  <li class="cd">
	    <span class="artist">Allen, Lily</span>
	    <span class="title">West End Girl</span>
	    <span class="year">2025</span>
	  </li>
	  <li class="cd">
	    <span class="artist">LCD Soundsystem</span>
	    <span class="title">This Is Happening</span>
	    <span class="year">2010</span>
	  </li>
	  <li class="cd">
	    <span class="artist">Bowie, David</span>
	    <span class="title">Blackstar</span>
	    <span class="year">2016</span>
	  </li>
	</ul>

And here's Web::Query pulling the artist and title out of each CD:

<!-- listing: c9/webquery.pl -->

	use v5.40;
	use Web::Query;

	wq('webquery.html')
	  ->find('.cd')
	  ->each(sub ($i, $) {
	      say $_->find('.artist')->text, ' - ', $_->find('.title')->text;
	  });

which prints:

	Allen, Lily - West End Girl
	LCD Soundsystem - This Is Happening
	Bowie, David - Blackstar

`wq()` (exported by the module) builds a Web::Query object from a
filename, a string of HTML, or a URL—it fetches the page for you if
you give it one, using LWP::UserAgent internally. `find` takes a CSS
selector, exactly like `document.querySelectorAll` in JavaScript or
`$(...)` in jQuery, and `each` iterates the matches, calling your
subroutine with two arguments, the index and the element. We don't need
the element, since `each` also sets `$_` to a Web::Query object wrapping
it, but a signature insists on the right number of arguments, so the bare
`$` in `($i, $)` accepts and ignores it. That lets you call
`find`/`text`/`attr` straight off `$_`—jQuery's `$(this)` pattern
translated into Perl.

Compare this to the HTML::TokeParser example above: there's no manual
walking of "get the sixth `<table>` tag, then the next `<font>` tag."
If the page's structure changes, you update a selector string instead
of a chain of `get_tag` calls. That said, `.cd`/`.artist`/`.title`
class names are doing you a favor here—a real page rarely provides
such helpfully named hooks, so the harder part of web scraping is
usually finding the right selector in the first place, not writing
the Perl to use it once you have.

Web::Query last saw a release in January 2024, which for a small,
focused module like this is a sign of stability rather than
neglect—the interface hasn't needed to change.

Further information
-------------------

[LWP](https://metacpan.org/pod/LWP) and [HTML::Parser](https://metacpan.org/pod/HTML::Parser) together with all of the other modules that we
have discussed in this section are not part of the standard Perl
distribution. You will need to download them from the CPAN (at
www.cpan.org). A very good place to get help with these modules is
the [LWP mailing list](https://lists.perl.org/list/libwww-perl.html). To subscribe, send a blank email to
*libwww-subscribe@perl.org* (but please make sure that you have read
all of the documentation that comes with the module before posting a
question).

Summary
-------

*  HTML is one of the most common data formats that you will come across because of its popularity on the World Wide Web.

*  You can retrieve HTML documents from the Internet using the LWP bundle of modules from the CPAN.

*  The main Perl module used for parsing HTML is [HTML::Parser](https://metacpan.org/pod/HTML::Parser), but you may well never need to use it, because subclasses like [HTML::LinkExtor](https://metacpan.org/pod/HTML::LinkExtor), [HTML::TokeParser](https://metacpan.org/pod/HTML::TokeParser), and [HTML::TreeBuilder](https://metacpan.org/pod/HTML::TreeBuilder) are often more useful for particular tasks.

*  Scraping web pages is fragile, because pages are written for people and their structure changes without warning. Prefer an API or a feed if there is one, and scrape defensively if there isn't.

*  [Web::Query](https://metacpan.org/pod/Web::Query) gives you a jQuery-style, CSS-selector interface for scraping, and is often quicker to reach for day to day than working with HTML::Parser directly.
