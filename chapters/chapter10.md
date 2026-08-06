Chapter 10: Common Data Interchange Formats
============================================

What this chapter covers:

* What's wrong with HTML as a data format, and what problem XML was designed to solve

* JSON and YAML, and why they've displaced XML for most everyday data interchange

* Parsing XML with XML::LibXML, using XPath and the Document Object Model

* Working with JSON and YAML, including a live weather API example

* Producing JSON, YAML, and XML from the same data

This chapter is about getting structured data into and out of your
programs in a format that other systems -- and other programmers --
can also read. Three formats dominate this space: XML, JSON, and
YAML. XML arrived first and largely defined the problem; JSON and
YAML came later and, for most day-to-day work, have taken over. All
three are still worth knowing: you'll meet XML in older systems and
in some corners of the enterprise world where it never went away,
JSON is close to the default for web APIs, and YAML turns up
everywhere configuration files are hand-written. We'll look at what
problem each format solves and why people ended up preferring one
over another, then spend the rest of the chapter parsing and
producing all three in Perl.

Data interchange formats
-------

One of the problems we had when extracting the weather information
from the web page in the [previous chapter](ch014.xhtml) was that it was difficult to
know where in the page to find the data we needed. The only way to do
it was to closely examine the HTML file and work out which tags
surrounded our required data. This also meant that each time the
design of the page was changed, we would have to rework our program.

### What’s wrong with HTML?

The reason this was so difficult was that HTML was designed to model
the logical structure of a document, not the meaning of the various
elements. An HTML document makes it easy to recognize headings,
paragraphs, lists, and other publishing elements. You can tell when
an element should be printed in bold, but you don't know *why* it was
bold -- for emphasis, because it's a table row heading, or because
it's the temperature on a weather page.

Our task would be a lot easier if the mark-up in a document told us
more about the actual meaning of the data. In our weather example, it
would be nice if there was a `<forecast>` … `</forecast>` element that
surrounded the forecast description, and a `<temperature>` …
`</temperature>` element around each temperature figure -- ideally
with attributes telling us whether it was a maximum or minimum, and
in which units.

### XML

XML -- the *Extensible Mark-up Language* -- was designed to solve
exactly this problem. It isn't really a mark-up language itself, but
a way of defining new mark-up languages suited to particular tasks.
Applied to our weather example, we might end up with something like
this:

    <forecast>
    <outlook>
    Partly Cloudy
    </outlook>
    <temperature type="MAX" degrees="C">12</temperature>
    <temperature type="MIN" degrees="C">6</temperature>
    </forecast>

Now the data is marked up to show what each piece of information
*is*, rather than how it should be displayed, so a program can pull
out the values it needs without caring how the document happens to be
laid out.

XML also has a formal side that JSON and YAML mostly do without:
elements and attributes can be constrained by a *Document Type
Definition* (DTD) or an XML Schema, which defines exactly which
elements are allowed, in what order, and with what attributes. A
document that merely follows XML's own syntax rules -- one top-level
element, every tag closed, attributes quoted, and so on -- is called
*well-formed*; one that also conforms to a DTD or schema is *valid*.
Most of the XML you'll encounter day to day is only ever checked for
well-formedness, and that's the only property Perl's XML tools verify
by default.

### JSON

[JSON](https://www.json.org/) -- *JavaScript Object Notation* -- describes
the same kind of data with far less ceremony. It has exactly two
structures, objects (`{ }`, unordered key/value pairs) and arrays
(`[ ]`, ordered lists), built out of strings, numbers, booleans, and
`null`. Our weather forecast looks like this in JSON:

    {
      "outlook": "Partly Cloudy",
      "temperatures": [
        { "type": "MAX", "degrees": "C", "value": 12 },
        { "type": "MIN", "degrees": "C", "value": 6 }
      ]
    }

Two things explain why JSON overtook XML for most data-interchange
work. First, it maps directly onto the data structures Perl (and
almost every other language) already has -- objects become hashes,
arrays become arrays -- so there's no impedance mismatch to think
about, unlike XML's tree of elements and attributes, which needs
translating into a hash or array before you can do anything useful
with it. Second, it's simply less to write and read: no closing tags,
no attribute-vs-element distinction, no DTD required. It also grew up
alongside the web, where it's now the default format returned by
practically every API you'll ever call.

### YAML

[YAML](https://yaml.org/) -- *YAML Ain't Markup Language* -- takes a
different approach again: instead of brackets and braces, structure
comes from indentation, in the same spirit as Python. The same data
looks like this:

    outlook: Partly Cloudy
    temperatures:
      - type: MAX
        degrees: C
        value: 12
      - type: MIN
        degrees: C
        value: 6

YAML was designed with humans doing the reading and writing, not just
programs. Keys don't need quoting, commas aren't required between
list items, and, unlike JSON, YAML allows comments -- all of which
makes it a popular choice for files people edit by hand, such as
configuration files (this is also why so many CI and deployment tools
use it). It's less commonly used than JSON as a wire format between
programs, but the two are close relatives: YAML 1.2 was deliberately
designed as a superset of JSON, so any valid JSON document is also
valid YAML.

In short: reach for JSON when you're talking to a web API or another
program, YAML when a human needs to read or edit the file, and expect
to meet XML when you're dealing with an older or more document-centric
system, or one with a genuine need for a formal schema. The rest of
this chapter shows how to work with all three in Perl.

Parsing XML with XML::LibXML
-------

There are a number of Perl XML parsers on CPAN, but for years now the
one almost everyone reaches for is
[XML::LibXML](https://metacpan.org/pod/XML::LibXML). It's a Perl
binding for `libxml2`, the C library that also powers XML support in
GNOME, PHP, and a long list of other tools -- so it's fast, actively
maintained, and standards-compliant. It also does two jobs at once
that used to belong to separate modules: it builds a full Document
Object Model (DOM) of a document, and it lets you query that DOM with
[XPath](https://en.wikipedia.org/wiki/XPath), a small language for
picking out the parts of an XML document you actually care about.

### Example: parsing weather.xml

Here's `XML::LibXML` reading our sample weather document:

    use v5.40;
    use XML::LibXML;

    my $dom = XML::LibXML->load_xml(location => shift);

    (my $outlook = $dom->findvalue('/forecast/outlook')) =~ s/^\s+|\s+$//g;
    say "Outlook: $outlook";

    for my $temp ($dom->findnodes('/forecast/temperature')) {
        say $temp->getAttribute('type'), ': ', $temp->textContent,
            ' ', $temp->getAttribute('degrees');
    }

Running this against our sample weather XML document gives the same
result as before:

    Outlook: Partly Cloudy
    MAX: 12 C
    MIN: 6 C

`load_xml` reads and parses the file in one step and hands back a
document object. `findvalue` runs an XPath expression and returns the
text it matches -- here, `/forecast/outlook` means "the `outlook`
child of the top-level `forecast` element." `findnodes` works the same
way but returns a list of matching elements instead of text, which we
can then query directly with `getAttribute` and `textContent`. There's
no need to track which element we're currently inside, as the old
`Stream`-style parser required -- we just ask for the nodes we want.

### Walking a document you don't know the shape of

XPath is the right tool when you know what you're looking for. Some
tasks, though -- writing a generic pretty-printer, say -- need to walk
a document without knowing its structure in advance. `XML::LibXML`
supports that too, using the same node-by-node model as the DOM:

    use v5.40;
    use XML::LibXML;

    my $dom = XML::LibXML->load_xml(location => shift);
    walk($dom->documentElement, 0);

    sub walk ($node, $depth) {
        if ($node->nodeType == XML_ELEMENT_NODE) {
            my $attrs = join ', ',
                map { $_->name . ': ' . $_->value } $node->attributes;
            say '  ' x $depth, $node->nodeName, " [$attrs]";
            walk($_, $depth + 1) for $node->childNodes;
        }
        elsif ($node->nodeType == XML_TEXT_NODE) {
            (my $text = $node->textContent) =~ s/^\s+|\s+$//g;
            say '  ' x $depth, $text if length $text;
        }
    }

Run against the weather document, this prints:

    forecast []
      outlook []
        Partly Cloudy
      temperature [type: MAX, degrees: C]
        12
      temperature [type: MIN, degrees: C]
        6

`documentElement` gets us the top-level element to start from, and
`attributes` and `childNodes` return plain lists directly, rather than
the `NodeList` objects with their own `getLength`/`item` methods that
older DOM-style modules used -- one of several places where
`XML::LibXML`'s API is just less ceremony for the same job.

### Handling parse errors

`XML::LibXML` is no more forgiving of broken XML than any other
standards-compliant parser: a document that isn't well-formed throws a
fatal exception. Catching it works exactly as you'd expect:

    eval { XML::LibXML->load_xml(location => $file) };
    if ($@) {
      die "Bad XML Document: $file\n";
    } else {
      say "Good XML!";
    }

### A note on very large documents

Loading a whole document into a DOM is convenient, but it means
holding the entire thing in memory -- fine for a weather forecast, less
fine for a multi-gigabyte export file. For cases like that,
`XML::LibXML::Reader` provides a pull-parser interface: it steps
through the document one node at a time, letting you process and
discard each part as you go, without ever building the full tree. It's
worth knowing about if you outgrow the DOM approach, though most of
the documents you'll meet day to day are small enough that it's not
something you need to reach for.

### Older modules you may still meet

Before `XML::LibXML` became the default choice, Perl's XML parsing was
mostly built around [XML::Parser](https://metacpan.org/pod/XML::Parser)
(a wrapper around the Expat C library, with several different parsing
styles -- Stream, Tree, Objects, and Handlers, among others) and
[XML::DOM](https://metacpan.org/pod/XML::DOM), which added a separate
DOM layer on top of it. Both are still on CPAN and you'll come across
them in older code, but neither is actively developed any more, and
everything they do is covered -- more directly, and usually in less
code -- by `XML::LibXML`.

Specialized parsers—XML::RSS
-------

Some of the subclasses of [XML::Parser](https://metacpan.org/pod/XML::Parser) are specialized to deal with
particular types of XML documents, *i.e.*, documents which conform to a
particular DTD. As an example we will look at one of the most popular
of these parsers, [XML::RSS](https://metacpan.org/pod/XML::RSS).

### What is RSS?

As you can probably guess, [XML::RSS](https://metacpan.org/pod/XML::RSS) parses rich site summary (RSS)
files. The RSS format has become very popular among web sites that
want to exchange ideas about the information they are currently
displaying. This is most often used by news-based sites, as they can
create an RSS file containing their current headlines and other sites
can grab the file and create a list of the headlines on a web page.

Quite a community of RSS-swapping has built up around these files. My
Netscape and Slashdot are two of the biggest sites using this
technology. Chris Nandor has built a web site called My Portal which
demonstrates a web page which users can configure to show news stories
from the sources which interest them.

### A sample RSS file

Here is an example of an RSS file for a fictional news site called
Dave’s news.

     <?xml version="1.0" encoding="UTF-8"?>

     <!DOCTYPE rss PUBLIC "//Netscape Communications//DTD RSS 0.91//EN"
       "http://my.netscape.com/publish/formats/rss-0.91.dtd">

     <rss version="0.91">

     <channel>
       <title>Dave's News</title>
       <link>http://daves.news</link>
       <description>All the news that's unfit to print!</description>
       <language>en</language>
       <pubDate>Wed May 10 21:06:38 2000</pubDate>
       <managingEditor>ed@daves.news</managingEditor>
       <webMaster>webmaster@daves.news</webMaster>

       <image>
         <title>Dave's News</title>
         <url>http://daves.news/images/logo.gif</url>
         <link>http://daves.news</link>
       </image>

       <item>
         <title>Data Munging Book tops best sellers list</title>
         <link>http://daves.news/cgi-bin/read.pl?id=1</link>
       </item>

       <item>
         <title>Microsoft abandons ASP for Perl</title>
         <link>http://daves.news/cgi-bin/read.pl?id=2</link>
       </item>

       <item>
         <title>Gates offers job to Torvalds</title>
         <link>http://daves.news/cgi-bin/read.pl?id=3</link>
       </item>

     </channel>
     </rss>

I hope you can see that the structure is very simple. The first thing
to notice is that because the file could potentially be processed
using a validating parser, it needs a reference to a `DOCTYPE` (or DTD).
This is given on the second line and points to version 0.91 of the DTD
(which, you’ll notice, was defined by Netscape). After the DOCTYPE
definition, the next line opens the top-level element, which is called
`<rss>`. Within one RSS file you can define multiple channels; however,
most RSS files will contain only one channel.

With the channel element you can define a number of data items which
define the channel. Only a subset of the possible items is used in
this example. The next complex data item is the `<image>` element. This
element defines an image which a client program can display to
identify your channel. You can define a URL to fetch the image from, a
title, and a link. It is obviously up to the client program how this
information is used, but if the channel was being displayed in a
browser, it might be useful to display the image as a hot link to the
given URL and to use the title as the `ALT` text for the image.

After the image element comes a list of the items which the channel
contains. Once more, the exact use of this information is up to the
client application, but browsers often display the title as a hot link
to the given URL. Notice that the URLs in the list of items are to
individual news stories, whereas the earlier URLs were to the main
page of the site.

### Example: creating an RSS file with XML::RSS

[XML::RSS](https://metacpan.org/pod/XML::RSS) differs from other XML parsers that we have seen as it can
also be used to create an RSS file. Here is the script that I used to
create the file given above:

     #!/usr/bin/perl
     use strict;
     use warnings;
     use XML::RSS;

     my $rss = XML::RSS->new;

     $rss->channel(
       title => "Dave's News",
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

As you can see, [XML::RSS](https://metacpan.org/pod/XML::RSS) makes the creation
of RSS files almost trivial. You create an RSS object using the class’s new
method and then add a channel using the channel method. The named parameters to
the channel method are the various subelements of the `<channel>` element in the
RSS file. I’m only using a subset here. The full set is described in the
documentation for the [XML::RSS](https://metacpan.org/pod/XML::RSS) which you
can access by typing `perldoc XML::RSS` from your command line once you have
installed the module.

The image method is used to add image information to the RSS object. Once more,
the various subelements of the `<image>` element are passed as named parameters
to the method. For each item that you wish to add to the RSS file, you call the
`add_item` method. Finally, to write the RSS object to a file you use the `save`
method. You could also use the `as_string` method, which will return the XML that
your RSS object generates.

### Example: parsing an RSS file with XML::RSS

Interpreting an RSS file using [XML::RSS](https://metacpan.org/pod/XML::RSS) is just as simple. Here is a
script which displays some of the more useful data from an RSS file.

    use strict;

    use XML::RSS;

    my $rss = XML::RSS->new;

    $rss->parsefile(shift);

    print $rss->channel('title'), "\n";
    print $rss->channel('description'), "\n";
    print $rss->channel('link'), "\n";
    print 'Published: ', $rss->channel('pubDate'), "\n";
    print 'Editor: ', $rss->channel('managingEditor'), "\n\n";

    print "Items:n";

    foreach (@{$rss->items}) {
      print $_->{title}, "nt<", $_->{link}, ">n";
    }

The file is parsed using the parsefile method (which [XML::RSS](https://metacpan.org/pod/XML::RSS)
overrides from its parent [XML::Parser](https://metacpan.org/pod/XML::Parser)). This method adds data
structures modeling the RSS file to the RSS parser object. This data
can be accessed using various accessor methods. The `channel` method
gives you access to the various parts of the `<channel>` element, and
the items method returns a list of the items in the file. Each
element in the items list is a reference to a hash containing the
various attributes of one item from the file.

If we run this script on our sample RSS file, here is the output that
we get.

    Dave's News
    All the news that's unfit to print!
    http://daves.news
    Published: Wed May 10 21:06:38 2000
    Editor: ed@daves.news

    Items:
    Data Munging Book tops best sellers list
        <http://daves.news/cgi-bin/read.pl?id=1>
    Microsoft abandons ASP for Perl
        <http://daves.news/cgi-bin/read.pl?id=2>
    Gates offers job to Torvalds
        <http://daves.news/cgi-bin/read.pl?id=3>

This example script only displays very basic information about the RSS file, but
it should be simple to expand it to display more details and to produce an HTML
page instead of text. There are a number of example scripts in the
[XML::RSS](https://metacpan.org/pod/XML::RSS) distribution which you can use as
a basis for your scripts.

Working with JSON
-------

Perl has no built-in JSON support, but CPAN has plenty of modules that
add it. The one to reach for is
[JSON::MaybeXS](https://metacpan.org/pod/JSON::MaybeXS): it automatically
uses the fastest JSON backend installed on your system (`Cpanel::JSON::XS`
or `JSON::XS`), and falls back to a pure-Perl implementation if neither
is available, so your code works everywhere without you having to
think about which backend it's actually running on.

### Example: today's weather, live from an API

Back in [Chapter 9](ch014.xhtml) we scraped a Yahoo! weather page for a forecast.
That page is long gone now, which is really the whole problem with
scraping HTML in the first place: it was written for people to read,
not programs, and it can change or disappear without warning. The
modern equivalent is to call a weather *API* -- a service that returns
data, not a page designed for a browser. Here's the same job done
properly, using [Open-Meteo](https://open-meteo.com/), a free weather
API that needs no signup or API key:

    use v5.40;
    use HTTP::Tiny;
    use JSON::MaybeXS;

    my %description = (
        0 => 'Clear sky',        1 => 'Mainly clear',
        2 => 'Partly cloudy',    3 => 'Overcast',
        45 => 'Fog',             48 => 'Depositing rime fog',
        51 => 'Light drizzle',   53 => 'Moderate drizzle',
        55 => 'Dense drizzle',   61 => 'Slight rain',
        63 => 'Moderate rain',   65 => 'Heavy rain',
        71 => 'Slight snow',     73 => 'Moderate snow',
        75 => 'Heavy snow',      80 => 'Rain showers',
        95 => 'Thunderstorm',
    );

    my ($lat, $lon) = (51.5072, -0.1276);   # Central London
    my $url = 'https://api.open-meteo.com/v1/forecast'
        . "?latitude=$lat&longitude=$lon"
        . '&current=temperature_2m,weather_code'
        . '&daily=temperature_2m_max,temperature_2m_min,weather_code'
        . '&timezone=Europe%2FLondon';

    my $res = HTTP::Tiny->new->get($url);
    die "Request failed: $res->{status} $res->{reason}\n" unless $res->{success};

    my $forecast = decode_json($res->{content});

    my $now = $forecast->{current};
    say "Now: $description{$now->{weather_code}}, $now->{temperature_2m}C";

    my $today = $forecast->{daily};
    say "Today: $description{$today->{weather_code}[0]}, "
      . "$today->{temperature_2m_min}[0]C to $today->{temperature_2m_max}[0]C";

Running it gives something like:

    Now: Partly cloudy, 19C
    Today: Partly cloudy, 14C to 22C

`HTTP::Tiny` -- a core module, so nothing extra to install -- fetches
the URL, and `decode_json` (exported by `JSON::MaybeXS`) turns the
response body straight into a Perl data structure: `current` is a
hash of conditions right now, and `daily` is a hash of arrays, one
entry per forecast day, of which we only look at today (index `0`).
The API reports weather as a numeric
[WMO code](https://open-meteo.com/en/docs) rather than a text
description, so `%description` translates the codes we're likely to
see into something readable.

Compare this with the `weather.xml` example earlier in the chapter:
there's no separate parsing step followed by pulling values out
attribute by attribute. `decode_json` hands you the finished data
structure in a single call, because a JSON document already has the
same shape as the Perl value it describes -- that's the main reason
it's so much less code than the equivalent XML handling. The reverse
operation, turning a data structure back into JSON text, is just as
direct; we'll use it in the next example.

Working with YAML
-------

JSON is a great fit for talking to an API, but it's not a format
people enjoy hand-editing -- every key needs quoting, commas have to
be exactly right, and you can't leave yourself a comment. YAML's
whole reason for existing is to be pleasant for humans to write and
read, which makes it a natural choice for configuration: rather than
hard-coding one city's coordinates into the script, let's read a list
of cities from a YAML file.

Here's `cities.yaml`:

    - name: London
      latitude: 51.5072
      longitude: -0.1276
    - name: Manchester
      latitude: 53.4808
      longitude: -2.2426
    - name: Glasgow
      latitude: 55.8642
      longitude: -4.2518

And the script that reads it:

    use v5.40;
    use HTTP::Tiny;
    use JSON::MaybeXS;
    use YAML::PP;

    my %description = ( ... );   # as before

    my $cities = YAML::PP->new->load_file('cities.yaml');

    for my $city (@$cities) {
        my $url = 'https://api.open-meteo.com/v1/forecast'
            . "?latitude=$city->{latitude}&longitude=$city->{longitude}"
            . '&current=temperature_2m,weather_code';

        my $res = HTTP::Tiny->new->get($url);
        next unless $res->{success};

        my $now = decode_json($res->{content})->{current};
        say "$city->{name}: $description{$now->{weather_code}}, "
          . "$now->{temperature_2m}C";
    }

`YAML::PP->new->load_file` reads the file straight into an array of
hashes -- exactly the structure `decode_json` would have built from
the equivalent JSON. That's the point worth taking away from seeing
JSON and YAML side by side: they mostly differ in how the data is
*written down*, not in what shape it ends up in once parsed. Adding a
fourth city means editing a text file, not touching the program,
which is exactly the job YAML is suited for and JSON, with its
stricter and less forgiving syntax, is not.

Producing different document formats
-------------------------------------

One of the most useful things about parsing a document into a plain
Perl data structure is that, once you've done it, you're no longer
tied to the format you started in. That's really the point of this
chapter: JSON, YAML, and XML are just three different ways of writing
down the same data, and once it's sitting in memory as an ordinary
Perl array or hash, converting between them is almost an afterthought.

As an example, let's go back to the CD collection data we've used
throughout the book -- but imagine it's arriving from an older system
as an XML feed:

    <?xml version="1.0" encoding="UTF-8"?>
    <cds>
      <cd artist="Bragg, Billy" title="Workers' Playtime"
          label="Cooking Vinyl" released="1988">
        <track>She's Got A New Spell</track>
        <track>Must I Paint You A Picture</track>
      </cd>
      <cd artist="Bragg, Billy" title="Mermaid Avenue"
          label="EMI" released="1998">
        <track>Walt Whitman's Niece</track>
        <track>California Stars</track>
      </cd>
      <cd artist="Black, Mary" title="The Holy Ground"
          label="Grapevine" released="1993">
        <track>Summer Sent You</track>
        <track>Flesh And Blood</track>
      </cd>
      <cd artist="Black, Mary" title="Circus"
          label="Grapevine" released="1995">
        <track>The Circus</track>
        <track>In A Dream</track>
      </cd>
      <cd artist="Bowie, David" title="Hunky Dory"
          label="RCA" released="1971">
        <track>Changes</track>
        <track>Oh You Pretty Things</track>
      </cd>
      <cd artist="Bowie, David" title="Earthling"
          label="EMI" released="1997">
        <track>Little Wonder</track>
        <track>Looking For Satellites</track>
      </cd>
    </cds>

We want to work with this data as JSON internally, and hand a copy to
a colleague who prefers YAML. Here's the whole program:

    use v5.40;
    use XML::LibXML;
    use JSON::MaybeXS;
    use YAML::PP;

    my $dom = XML::LibXML->load_xml(location => 'cds.xml');

    my @cds = map {
        {
            artist   => $_->getAttribute('artist'),
            title    => $_->getAttribute('title'),
            label    => $_->getAttribute('label'),
            released => $_->getAttribute('released'),
            tracks   => [ map { $_->textContent } $_->findnodes('./track') ],
        }
    } $dom->findnodes('/cds/cd');

    say JSON->new->utf8->pretty->encode(\@cds);
    say YAML::PP->new->dump_string(\@cds);

That's the whole thing. `load_xml` reads the file and gives us a DOM
we can query with XPath; `findnodes('/cds/cd')` returns a list of
`<cd>` elements, and the `map` turns each one into the same plain
hash -- with an array of track names -- that we've built for this
data throughout the book, using `getAttribute` for the attributes and
a nested `findnodes('./track')` to pick up the tracks. Once `@cds`
holds that, `JSON::MaybeXS` and `YAML::PP` do the rest: each one is a
single method call, because by then the hard work -- deciding what
the data actually *means* -- is already finished.

Compare that with the older, node-by-node approach of walking a
generic tree: `XML::LibXML`'s XPath support lets us go straight from
"the things I care about" (`cd` elements, their attributes, their
`track` children) to a data structure, rather than visiting every
node in turn and working out which branch we're looking at as we go.
That's why this version is a fraction of the length of the equivalent
program from a few years ago.

### Going back the other way

It's just as possible to build XML from `@cds` -- if that colleague's
system needed to hand data back to the legacy one, we'd create an
`XML::LibXML::Document`, add a `<cd>` element for each hash with
`createElement` and `setAttribute`, and append a `<track>` child
element for each track. It's more code than the JSON or YAML side,
simply because XML has more ceremony than either of those formats --
which is as good a reason as any why JSON and YAML have largely
displaced XML for this kind of everyday data interchange. The full
recipe is in the documentation for
[XML::LibXML::Document](https://metacpan.org/pod/XML::LibXML::Document)
if you need it.

Further information
-------------------

If you want to go deeper on the XML side specifically, the best way to
keep abreast of the latest news is to read the
[Perl-XML mailing list](https://lists.perl.org/list/perl-xml.html). You
can subscribe via the web interface at:

    https://lists.perl.org/list/perl-xml.html

Most of the modules discussed in this chapter -- `XML::LibXML`,
`XML::RSS`, `JSON::MaybeXS`, `YAML::PP` -- are not installed as part
of the standard Perl installation, and you'll need to get them from
the CPAN. The exception is `HTTP::Tiny`, which has been part of core
Perl since 5.14.

Summary
-------

* XML, JSON, and YAML all solve the same underlying problem -- getting structured data into and out of your programs -- with different trade-offs between formality, brevity, and human-friendliness.

* XML documents can be either valid or well-formed. Currently, no Perl XML parser checks for validity.

* XML parsing in Perl is very easy using [XML::LibXML](https://metacpan.org/pod/XML::LibXML), which combines the industry-standard Document Object Model with XPath for picking out just the data you need.

* Older modules such as [XML::Parser](https://metacpan.org/pod/XML::Parser) and [XML::DOM](https://metacpan.org/pod/XML::DOM) are still around and you'll meet them in older code, but [XML::LibXML](https://metacpan.org/pod/XML::LibXML) does everything they do, more directly and in less code.

* Specialized parsers such as [XML::RSS](https://metacpan.org/pod/XML::RSS) can be used to parse documents conforming to specific DTDs.

* [JSON::MaybeXS](https://metacpan.org/pod/JSON::MaybeXS) is the standard choice for JSON in Perl -- it's fast where a fast backend is installed, and works everywhere regardless.

* JSON is close to the default format for talking to web APIs, and decodes straight into ordinary Perl data structures with no separate parsing step.

* [YAML::PP](https://metacpan.org/pod/YAML::PP) reads and writes YAML, which is worth reaching for when a human, not just a program, needs to read or edit the file -- configuration being the classic case.
