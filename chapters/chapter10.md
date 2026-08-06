Chapter 10: XML
===============

What this chapter covers:

* What is XML and what’s wrong with HTML?

* Parsing XML

* Using handlers to control the parser

* Parsing XML using the Document Object Model

* Converting an XML document to POD, HTML, or plain text

Over the next few years, it looks as though XML will become the data
exchange format of choice for a vast number of computer systems. In
this chapter we will take a look at some of the tools available for
parsing XML with Perl.

XML overview
-------

One of the problems we had when extracting the weather information
from the web page in the [previous chapter](ch014.xhtml) was that it was difficult to
know where in the page to find the data we needed. The only way to do
it was to closely examine the HTML file and work out which tags
surrounded our required data. This also meant that each time the
design of the page was changed, we would have to rework our program.

### What’s wrong with HTML?

The reason this was so difficult was that HTML was designed to model
the logical  structure of a document, not the meaning of the various
elements. For example, an  HTML document makes it easy to recognize
headings at various levels, paragraphs,  lists, and various other
publishing elements. You can tell when an element should  be printed
in bold, but the problem is that you don’t know *why* that particular
element was bold. It could be purely for emphasis, it could be
because it is a row heading in a table, or it could be because it
is the temperature on a weather page.

Our task would be a lot easier if the mark-up in a document told us
more about   the actual meaning of the data. In our weather example,
it would be nice if there was  a `<FORECAST>` … `</FORECAST>` element that
surrounded the actual forecast description and perhaps a
`<TEMPERATURE>` … `</TEMPERATURE>` element which surrounded  each of the
temperature figures in which we were interested. Even better, the
`<TEMPERATURE>` element could have attributes which told us whether it
was a maximum or minimum temperature and whether it was in degrees
Fahrenheit or Celsius.

### What is XML?

This is exactly the kind of problem that XML was designed to solve.
XML is the  *Extensible Mark-up Language*. In fact it isn’t really a
mark-up language at all, it is a  method to define new mark-up
languages which are better suited to particular tasks.  The way it
works is by defining a syntax for *Document Type Definitions* (DTDs).
A  DTD defines the set of elements that are allowed in a document,
together with their  attributes and relationships to each other. It
will define which elements are mandatory or optional, whether there
is any defined order, and which elements can (or  must) contain other
elements. The exact syntax of DTDs is beyond the scope of this  book,
but there are a number of specialized books which cover it in some
detail (for  example [XML Pocket Reference](https://learning.oreilly.com/library/view/xml-pocket-reference/9780596100506/) by Robert Eckstein and
published by O’Reilly).  Going back to our weather forecast example,
we could design a DTD that defined a  file format for weather
forecasts. Let’s keep it very simple and say that a sample  would look
like this:

     <FORECAST>
     <OUTLOOK>
     Partly Cloudy
     </OUTLOOK>
     <TEMPERATURE TYPE="MAX" DEGREES="C">12</TEMPERATURE>
     <TEMPERATURE TYPE="MIN" DEGREES="C">6</TEMPERATURE>
     </FORECAST>

If Yahoo! (or any other information provider) made a file available
in this format then we could download it from the Internet and parse
it using Perl to extract the relevant information. If the parser that
we wrote was sophisticated enough, Yahoo! could reorder the contents
of the source file and we would still be able to access the data.
This is because the file is marked up to show what each data element
is, not how it should be displayed.

#### Valid vs. well-formed

It’s worth stopping at this point to discuss a couple of XML concepts.
There are two levels of XML correctness. A correct XML document can be
said to be *valid* or it can be said to be *well-formed*. Well-formed
is the easier criterion to adhere to. This means that the document is
syntactically correct or, in other words, it follows all of the
general rules for XML documents. Basically, these rules say this:

* The document must have one top-level element.

* All elements must have opening and closing tags (except in the special case of empty tags where the opening tag is also used as the closing tag).

* Opening and closing tags must be nested correctly (*i.e.*, nested tags must be closed in the reverse of the order in which they were opened).

* All attributes must be quoted and cannot contain a `<` or an `&` (except as the first character of a reference).

Our sample weather document fulfills all of these constraints and is,
therefore, well-formed. It cannot, however, be described as valid. A
valid document is one that follows the rules laid down in a DTD. This
means that it must have all of the correct elements in the right
order and any nesting of elements must also be in combinations
sanctioned by the DTD. If we wrote a weather DTD and wrote our
weather document to conform with that DTD then we could call it
valid. Currently, we don’t have such a DTD so there is no way that
our document can be valid.

XML parsers fall into two types. Validating parsers will check the
document’s structure against its DTD and nonvalidating parsers only
check that the document is well-formed.

Parsing XML with XML::Parser
-------

Of course there are Perl XML parsers available. The most generalized one is the
CPAN module [XML::Parser](https://metacpan.org/pod/XML::Parser). This module is
based on an XML parser called [Expat](https://libexpat.github.io). Expat is a
nonvalidating parser, so in Perl you will generally only be interested in the
well-formedness of documents.

I hope this explains my reluctance to go into the details of
DTDs—[XML::Parser](https://metacpan.org/pod/XML::Parser) makes no use of them.
There is, however, an experimental subclass of [XML::Parser](https://metacpan.org/pod/XML::Parser), called
[XML::Checker::Parser](https://metacpan.org/pod/XML::Checker::Parser), which does validate an XML document against a DTD.

[XML::Parser](https://metacpan.org/pod/XML::Parser) works in a similar way to
[HTML::Parser](https://metacpan.org/pod/HTML::Parser), but as XML is more
complex than HTML, [XML::Parser](https://metacpan.org/pod/XML::Parser) needs to
be more complex than [HTML::Parser](https://metacpan.org/pod/HTML::Parser).

### Example: parsing weather.xml

As an example of using [XML::Parser](https://metacpan.org/pod/XML::Parser), here
is a simple script to parse our weather XML file:

    use strict;
    use XML::Parser;
    my %forecast;
    my @curr;
    my $type;

    my $p = XML::Parser->new(Style => 'Stream');
    $p->parsefile(shift);
    print "Outlook: $forecast{outlook}n";

    foreach (keys %forecast) {
      next if /outlook/;
      print "$_: $forecast{$_}->{val} $forecast{$_}->{deg}n";
    }

    sub StartTag {
      my ($p, $tag) = @_;
      push @curr, $tag;
      if ($tag eq 'TEMPERATURE') {
        $type = $_{TYPE};
        $forecast{$type}->{deg} = $_{DEGREES};
      }
    }

    sub EndTag {
      pop @curr;
    }

    sub Text {
      my ($p) = shift;
      return unless /S/;
      s/^s+//;
      s/s+$//;
      if ($curr[-1] eq 'OUTLOOK') {
        $forecast{outlook} .= $_;
      } elsif ( $curr[-1] eq 'TEMPERATURE') {
        $forecast{$type}->{val} = $_;
      }
    }

Running this script against our sample weather XML document gives the
following result:

    Outlook: Partly Cloudy
    MAX: 12 C
    MIN: 6 C

### Using XML::Parser

There are a number of different ways to use [XML::Parser](https://metacpan.org/pod/XML::Parser). In this
example we are using it in a very similar manner to [HTML::Parser](https://metacpan.org/pod/HTML::Parser).
When we create the parser object we pass it a hash containing various
configuration options. In this case, the hash consists of one key
(`Style`) and an associated value, which is the string `Stream`. The
`Style` parameter tells [XML::Parser](https://metacpan.org/pod/XML::Parser) that we want to use one of a number
of built-in parsing methods. The one that we want to use in this
example is called Stream. In this mode [XML::Parser](https://metacpan.org/pod/XML::Parser) works very
similarly to [HTML::Parser](https://metacpan.org/pod/HTML::Parser). There are a number of predefined methods
which the parser will call when encountering various parts of the XML
document. For this example we need to define three of these methods.
`StartTag` is called when the start of an XML tag is found, `EndTag` is
called when the end of a tag is seen, and `Text` is called when text
data is encountered. In each case the first parameter to the function
will be a reference to the underlying Expat object which is doing the
parsing. In the `StartTag` and `EndTag` functions the second parameter is
the name of the tag which is being started or ended. The complete
original tag is stored in `$_`. Additionally, in the `StartTag` function,
the list of attributes is stored in `%_`. In the `Text` function, the
text that has been found is stored in `$_`.

This may all make a bit more sense if we look at the example code in
more detail. The main part of the program defines some global
variables, creates the parser, parses the file, and displays the
information which has been extracted. The global variables which it
defines are: `%forecast`, which will store the forecast data that we
want to display, `@curr` which is a list of all of the current elements
that we are in, and `$type` which stores the current temperature type.
All of the real work goes on in the parsing functions which are called
by the parser as it processes the file.

The `StartTag` function pushes the new tag on to the end of the `@curr` array,
and if the tag starts a `TEMPERATURE` element, it stores the values of the
`TYPE` and `DEGREES` attributes (which it finds in `%_`). The `EndTag` function
simply pops the last element from the `@curr` array. You might think that we
should check whether the tag that we are ending is of the same type as the
current end of this list but, if it wasn’t the case, the document wouldn’t be
well-formed and would, therefore, fail the parsing process. This always throws a
fatal exception, but there are ways to prevent your program from dying if you
give it non-well-formed XML, as we will see later.

The Text function checks whether there is useful data in the text
string (which is stored in `$_`) and returns if it can’t find at least
one nonspace character. It then strips leading and trailing spaces
from the data. If the current element we are processing (given by
`$curr[-1]`) is the `OUTLOOK` element, then the text must be the outlook
description and we store it in the appropriate place in the
`%forecast` variable. If the current element is a `TEMPERATURE` element,
`%then` the text
will be the temperature data and that is also stored in the %forecast
hash (making use of the current temperature type which is stored in
the global `$type` variable).

Once the parsing is complete the data is all stored in the `%forecast`
hash and we can traverse the hash to display the required data. Notice
that the method that we use for this makes no assumptions about the
list of temperature types used. If we were to add average temperature
data to the weather document, our program would still display this.

#### Parsing failures

[XML::Parser](https://metacpan.org/pod/XML::Parser) (and the other parsers which are based on it) have a
somewhat harsh approach to non-well-formed XML documents. They will
always throw a fatal exception when they encounter non-well-formed
XML. Unfortunately, this behavior is defined in the XML
specifications, so they have no choice about this, but it can still
take beginners by surprise as they often expect the `parse` or
`parsefile` method to return an error code, but instead their entire
program is halted.

It’s difficult to see what processing you might want to proceed with
if your XML document is incorrect, so in many cases dying is the
correct approach for a program to take. If, however, you have a case
where you want to recover a little more gracefully you can catch the
fatal exception. You do this using `eval`. If the code that is passed
to `eval` causes an exception, the program does not `die`, but the error
message is put in the variable `$@`. You can therefore parse your XML
documents using code like this:

    eval { $p->parsefile($file) };
    if ($@) {
      die "Bad XML Document: $file\n";
    } else {
      print "Good XML!\n";
    }

### Other XML::Parser styles

The `Stream` style is only one of a number of styles which [XML::Parser](https://metacpan.org/pod/XML::Parser)
supports.

Depending on your requirements, another style might be better suited
to the task.

#### Debug

The `Debug` style simply prints out a stylized version of your XML
document. Parsing our weather example file using the `Debug` style gives
us the following output:

     \\ ()
     FORECAST || #10;
     FORECAST ||
     FORECAST \\ ()
     FORECAST OUTLOOK || #10;
     FORECAST OUTLOOK ||
     Partly Cloudy
     FORECAST OUTLOOK || #10;
     FORECAST OUTLOOK ||
     FORECAST //
     FORECAST || #10;
     FORECAST ||
     FORECAST \\ (TYPE MAX DEGREES C)
     FORECAST TEMPERATURE || 12
     FORECAST //
     FORECAST || #10;
     FORECAST ||
     FORECAST \\ (TYPE MIN DEGREES C)
     FORECAST TEMPERATURE || 6
     FORECAST //
     FORECAST || #10;
     //

If you look closely, you will see the structure of our weather
document in this display. A line containing the opening tag of a new
element contains the character sequence `\\` and the attributes of the
element appear in brackets. A line containing the character sequence
`//` denotes an element’s closing tag, and a line containing the
character sequence `||` denotes the text contained within an element.
The `#10` sequences denote the end of each line of text in the original
document.

#### Subs

The `Subs` style works in a very similar manner to the `Stream` style,
except that instead of the same functions being called for the start
and end tags of each element, a different pair of functions is called
for each element type. For example, in our weather document, the
parser would expect to find functions called `FORECAST` and `OUTLOOK` that
it would call when it found `<FORECAST>` and `<OUTLOOK>` tags. For the
closing tags, it would look for functions called `_FORECAST` and
`_OUTLOOK`. This method prevents the program from having to check which
element type is being processed (although this information is still
passed to the function as the second parameter).

#### Tree

All of the styles that we have seen so far have been *stream-based*.
That is, they move through the document and call certain functions in
your code when they come across particular events in the document. The
Tree style does things differently. It parses the document and builds
a data structure containing a logical model of the document. It then
returns a reference to this data structure.

The data structure generated by our weather document looks like this:

    [ 'FORECAST', [ {}, 0, "\n
    ",
    'OUTLOOK', [ {}, 0, "\n
    Partly Cloudy\n
    "], 0, "\n
    ",
    'TEMPERATURE', [ ( 'DEGREES' => 'C', 'TYPE' => 'MAX' }, 0, '12' ], 0,
    "\n ",
    'TEMPERATURE', [ ( 'DEGREES' => 'C', 'TYPE' => 'MAX' }, 0, '6'
    ], 0, "\n"
    ] ]

It’s probably a little difficult to follow, so let’s look at it in
detail.

Each element is represented by a list. The first item is the element
type and the second item is a reference to another list which
represents the contents of the element. The first element of this
second level list is a reference to a hash which contains the
attributes for the element. If the element has no attributes then the
reference to the hash still exists, but the hash itself is empty. The
rest of the list is a series of pairs of items, which represent the
text, and elements that are contained within the element. These pairs
of items have the same structure as the original two-item list, with
the exception that a text item has a special element type of `0`.

If you’re the sort of person who thinks that a picture is worth a
thousand words, then Figure 10.1 might have saved me a lot of typing.

![Output from XML::Parser Tree style](images/10-1-output-from-xml-parser-tree-style.png)

In the figure the variable `$doc` is returned from the parser. You can
also see the arrays which contain the definitions of the XML content
and the hashes which contain the attributes.

#### Example: using XML::Parser in Tree style

This may become clearer still if we look at some sample code for
dealing with one of these structures. The following program will print
out the structure of an XML document. Using it to process our weather
document will give us the following output:

     FORECAST []
     OUTLOOK []
     Partly Cloudy
     TEMPERATURE [DEGREES: C, TYPE: MAX]
     12
     TEMPERATURE [DEGREES: C, TYPE: MIN]
     6

 Here is the code:

    use strict;
    use XML::Parser;

    my $p = XML::Parser->new(Style => 'Tree');
    my $doc = $p->parsefile(shift);
    my $level = 0;

    process_node(@$doc);

    sub process_node {
      my ($type, $content) = @_;
      my $ind = ' ' x $level;
      if ($type) { # element
        my $attrs = shift @$content;
        print $ind, $type, ' [';
        print join(', ', map { "$_: $attrs->{$_}" } keys %{$attrs});
        print "]\n";
        ++$level;
        while (my @node = splice(@$content, 0, 2)) {
          process_node(@node); # Recursively call this subroutine
        }
        --$level;
      } else { # text
        $content =~ s/\n/ /g;
        $content =~ s/^\s+//;
        $content =~ s/\s+$//;
        print $ind, $content, "\n";
      }
    }

Let’s look at the code in more detail.

The start of the program looks similar to any number of other parsing programs
that we’ve seen in this chapter. The only difference is that we create our
[XML::Parser](https://metacpan.org/pod/XML::Parser) object with the `Tree`
style. This means that the `parsefile` method returns us a reference to our tree
structure.

As we’ve seen above, this is a reference to a list with two items in it. We’ll
call one of these two-item lists a *node* and write a function called
`process_node` which will handle one of these lists. Before calling
`process_node`, we initialize a global variable to keep track of the current
element nesting level.

In the `process_node` function, the first thing that we do is determine the type
of node we are dealing with. If it is an element, then the first item in the
node list will have a true value. Text nodes have the value `0` in this
position, which will evaluate as false. If we are dealing with an element, then
shifting the first element off of the content list will give us a reference to
the attribute hash. We can then print out the element type and attribute list
indented to the correct level.

Having dealt with the element and its attributes we can process its
contents. One advantage of using shift to get the attribute hash
reference is that it now leaves the content list with an even number
of items in it. Each pair of items is another node. We can simply use
splice to pull the nodes off the array one at a time and pass them
recursively to `process_node`, pausing only to increment the level
before processing the content and decrementing it again when finished.
If the node is text, then the second item in the node list will be the
actual text. In this case we just clean it up a bit and print it out.

#### Example: parsing weather.xml using the Tree style

This program will work with any tree structure that is generated by
[XML::Parser](https://metacpan.org/pod/XML::Parser) using the `Tree` style.
However, more often you will want to do something a little more specific to the
document with which you are dealing. In our case, this will be printing out a
weather forecast. Here is a `Tree`-based program for printing the forecast in
our usual format.

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
      s/\n/ /g;
      s/^\s+//;
      s/\s+$//;
      return $_;
    }

The basic structure of this program is quite similar to the previous
one. All of the work is still done in the `process_node` function. In
this version, however, we are on the lookout for particular element
types which we know we want to process. When we find an `OUTLOOK`
element or a `TEMPERATURE` element we know exactly what we need to do.
All other elements are simply ignored. In the case of an `OUTLOOK`
element we simply extract the text from the element and print it out.
Notice that the text contained within the element is found at
`$content->[2]`, the third item in the content array. This is true for
any element that only contains text, as the first two items in the
content list will always be a reference to the attribute hash and the
character `0`.

The processing for the `TEMPERATURE` element type is only slightly more
complex as we need to access the attribute hash to find out the type
of the temperature (minimum or maximum) and the kind of degrees in
which is it measured.

Notice that we still need to process any child elements and that this
is still done in the same way as in the previous program—by removing
nodes from the `@$content` list. In this case we haven’t removed the
attribute hash from the front of the list, so we start the splice from
the second item in the list (the second item has the index `0`).

#### Objects

The `Objects` style works very much like the `Tree` style, except that
instead of arrays and hashes, the document tree is presented as a
collection of objects. Each element type becomes a different object
class. The name of the class is created by appending `main::` to the
front of the element’s name.

This is the default
behavior. You can create your objects within other packages by using
the `Pkg` option to `XML::Parser->new`. For example:

    my $p = XML::Parser->new(
      Style => 'Objects',
      Pkg => 'Some_Other_Package'
    );

Text data is turned into an object of class `main::Characters`. The
value that is returned by the parse method is a reference to an array
of such objects. As a well-formed XML object can only have one
top-level element, this array will only have one element.

Attributes of the element are stored in the element hash. This hash
also contains a special key, `Kids`. The value associated with this key
is a reference to an array which contains all of the children of the
element.

#### Example: parsing XML with XML::Parser using the Objects style

Here is a program that displays the structure of any given XML
document using the `Objects` style:

    use strict;
    use XML::Parser;

    my $p = XML::Parser->new(Style => 'Objects');

    my $doc = $p->parsefile(shift);

    my $level = 0;

    process_node($doc->[0]);

    sub process_node {
      my ($node) = @_;

      my $ind = ' ' x $level;

      my $type = ref $node;
      $type =~ s/^.*:://;

      if ($type ne 'Characters') {
        my $attrs = {%$node};
        delete $attrs->{Kids};

        print $ind, $type, ' [';
        print join(', ', map { "$_: $attrs->{$_}" } keys %{$attrs});
        print "]\n";

        ++$level;
        foreach my $node (@{$node->{Kids}}) {
          process_node($node);
        }
        --$level;
      } else {
        my $content = $node->{Text};
        $content =~ s/\n/ /g;
        $content =~ s/^\s+//;
        $content =~ s/\s+$//;
        print $ind, $content, "\n" if $content =~ /\S/;
      }
    }

This program is very similar to the example that we wrote using the
Tree style. Once again, most of the processing is carried out in the
`process_node` function. In this case each node is represented by a
single reference rather than a two-item list. The first thing that we
do in `process_node` is to work out the type of element with which we
are dealing. We do this by using the standard Perl function [ref](https://perldoc.perl.org/functions/ref). This
function takes one parameter, which is a reference, and returns a
string containing the type of object that the reference refers to. For
example, if you pass it a reference to an array, it will return the
string `ARRAY`. This is a good way to determine the object type a
reference has been blessed into. In our case, each reference that we
pass to it will be of type `main::Element`, where `Element` is the name of
one of our element types. We remove the `main::` from the front of the
string to leave us with the specific element with which we are dealing.

If we are dealing with an element (rather than character data) we then take a
copy of the object hash which we will use to get the list of attributes. Notice
that we don’t use the more obvious `$attrs = $node` as this only copies the
reference and still leaves it pointing to the same original hash. As the next
line of the code deletes the `Kids` array reference from this hash, we use the
slightly more complex `$attrs = {%$node}` as this takes a copy of the original
hash and returns a reference to the new copy. We can then delete the `Kids`
reference without doing any lasting damage to the original object.

Having retrieved the attribute hash, we display the element type along
with its attributes. We then need to process all of the element’s
children. We do this by iterating across the `Kids` array (which is
why it’s a good idea that we didn’t delete the original earlier),
passing each object in turn to `process_node`.

If the object with which we are dealing is of the class `Characters`
then it contains character data and we can access the actual text by
using the special `Text` key.

#### Choosing between Tree and Object styles

The `Tree` and `Object` styles can both be used to address the same set of
problems. You would usually use one of these two styles when your
document processing requires multiple passes over the document
structure. Whether you choose the `Tree` or `Objects` style for your
tree-based parsing requirements is simply a matter of personal taste.

### XML::Parser handlers

The [XML::Parser](https://metacpan.org/pod/XML::Parser) styles that we have been
discussing are a series of prebuilt methods for parsing XML documents in a
number of popular ways. If none of these styles meet your requirements, there is
another way that you can use [XML::Parser](https://metacpan.org/pod/XML::Parser)
which gives even more control over the way it works. This is accomplished by
setting up a series of *handlers* which can respond to various events that are
triggered while parsing a document. This is very similar to the way we used
[HTML::Parser](https://metacpan.org/pod/HTML::Parser) or the `Stream` style of
[XML::Parser](https://metacpan.org/pod/XML::Parser).

Handlers can be set to process a large number of XML constructs. The most
obvious ones are the start and end of an XML element or character data, but you
can also set handlers for the XML declaration, various DTD definitions, XML
comments, processing instructions, and any other construct that you find in an
XML document.

You set handlers either by using the `Handlers` parameter when you create a
parser object, or by using the `setHandlers` method later on. If you use the
`Handlers` parameter then the value associated with the parameter should be a
reference to a hash. In this hash the keys will be handler names, and each value
will be a reference to the appropriate function.

Different handler functions receive different sets of parameters. The full set
of handlers and their parameters can be found in the
[XML::Parser](https://metacpan.org/pod/XML::Parser) documentation, but here is a
brief summary of the most frequently used ones:

* *Init*—Called before parsing of a document begins. It is passed a reference to the `Expat` parser object.

* *Final*—Called after parsing of a document is complete. It is passed a reference to the `Expat` parser object.

* *Start*—Called when the opening tag of an XML element is encountered. It is passed a reference to the `Expat` parser object, the name of the element, and a series of pairs of values which represents the name and value of the element’s attributes.

* *End*—Called when the closing tag of an XML element is encountered. It is passed a reference to the `Expat` parser object and the name of the element.

* *Char*—Called when character data is encountered. It is passed a reference to the `Expat` parser object and the string of characters that has been found. All of these subroutines are passed a reference to the `Expat` parser object. This is the actual object that [XML::Parser](https://metacpan.org/pod/XML::Parser) uses to parse your XML document. It is useful in some more complex parsing techniques, but at this point you can safely ignore it.

#### Example: parsing XML using XML::Parser handlers

Here is an example of our usual program for displaying the document
structure, rewritten to use handlers.

    use strict;
    use XML::Parser;

    my $p = XML::Parser->new( Handlers => {
      Init  => \&init,
      Start => \&start,
      End   => \&end,
      Char  => \&char});

    my ($level, $ind);
    my $text;

    $p->parsefile(shift);

    sub init {
      $level = 0;
      $text = '';
    }

    sub start {
      my ($p, $tag) = (shift, shift);

      my %attrs = @_ if @_;

      print $ind, $tag, ' [';
      print join ', ', map { "$_: $attrs{$_}" } keys %attrs;
      print "]\n";

      $level++;
      $ind = ' ' x $level;
    }

    sub end {
      print $ind, $text, "\n";
      $level--;
      $ind = ' ' x $level;
      $text = '';
    }

    sub char {
      my ($p, $str) = (shift, shift);

      return unless $str =~ /\S/;

      $str =~ s/^\s+//;
      $str =~ s/\s+$//;

      $text .= $str;
    }

In this case we only need to define four handlers for `Init`, `Start`,
`End`, and `Char`. The Init handler only exists to allow us to set `$level`
and `$text` to initial values.

In the `Start` handler we do very similar processing to the previous
examples. That is, we print the element’s name and attributes. In this
case it is very easy to get these values as they are passed to us as
parameters. We also increment `$level` and use the new value to
calculate an indent string which we will print before any output.

In the `End` handler we print out any text that has been built up in
`$text`, decrement `$level`, recalculate `$ind`, and reset `$text` to an empty
string.

In the `Char` handler we do the usual cleaning that strips any leading
and trailing white space and appends the string to `$text`. Notice that
it is possible that because of the way the parser works, any
particular sequence of character data can be split up and processed in
a number of calls to this handler. This is why we build up the string
and print it out only when we find the closing element tag. This would
be even more important if we were applying some kind of formatting to
the text before displaying it.

XML::DOM
-------

As we have seen, [XML::Parser](https://metacpan.org/pod/XML::Parser) is a very
powerful and flexible module, and one that can be used to handle just about any
XML processing requirement. However, it’s well known that one of the Perl
mottoes is that there’s more than one way to do it, and one of the cardinal
virtues of a programmer is Laziness (the other two being Impatience and Hubris,
according to Larry Wall). It should not therefore come as a surprise that there
are many other XML parser modules available from the CPAN. Some of these are
specialized to deal with XML that conforms to a particular DTD (we will look at
one of these a bit later), but many others present yet more ways to handle
general XML parsing tasks. Probably the most popular of these is
[XML::DOM](https://metacpan.org/pod/XML::DOM). This is a tree-based parser which
returns a radically different view of an XML document.

[XML::DOM](https://metacpan.org/pod/XML::DOM) implements the Document Object
Model. DOM is a way to access arbitrary parts of an XML document. DOM has been
defined by the World Wide Web Consortium (W3C), and is rapidly becoming a
standard method to parse and access XML documents.

[XML::DOM](https://metacpan.org/pod/XML::DOM) is a subclass of
[XML::Parser](https://metacpan.org/pod/XML::Parser), so
all[XML::Parser](https://metacpan.org/pod/XML::Parser) methods are still
available, but on top of these methods,
[XML::DOM](https://metacpan.org/pod/XML::DOM) implements a whole new set of
methods which allow you to walk the document tree.

### Example: parsing XML using XML::DOM

As an example of [XML::DOM](https://metacpan.org/pod/XML::DOM) in use, here is our usual document structure
script rewritten to use it.

    use strict;
    use XML::DOM;

    my $p = XML::DOM::Parser->new;

    my $doc = $p->parsefile(shift);

    my $level = 0;

    process_node($doc->getFirstChild);

    sub process_node {
      my ($node) = @_;

      my $ind = ' ' x $level;;

      my $nodeType = $node->getNodeType;
      if ($nodeType == ELEMENT_NODE) {
        my $type = $node->getTagName;

        my $attrs = $node->getAttributes;

        print $ind, $type, ' [';
        my @attrs;
        foreach (0 .. $attrs->getLength - 1) {
          my $attr = $attrs->item($_);
          push @attrs, $attr->getNodeName . ': ' . $attr->getValue;
        }
        print join (', ', @attrs);

        print "]\n";

        my $nodelist = $node->getChildNodes;

        ++$level;
        for (0 .. $nodelist->getLength - 1) {
          process_node($nodelist->item($_));
        }
        --$level;
      } elsif ($nodeType == TEXT_NODE) {
        my $content = $node->getData;
        $content =~ s/\n/ /g;
        $content =~ s/^\s+//;
        $content =~ s/\s+$//;
        print $ind, $content, "\n" if $content =~ /\S/;
      }
    }

A lot of the structure of this program will be very familiar by now,
so we will look at only the differences between this version and the
Tree style version.

You should first notice that the value returned by `parsefile` is a reference to
an object that represents the whole document. To get the single element which
contains the whole document, we need to call this object’s `getFirstChild`
method. We can then pass this reference to the `process_node` function.

Within the `process_node` function we still do exactly the same things that we
have been doing in previous versions of this script; it is only the way that we
access the data which is different. To work out the type of the current node, we
call its `getNodeType` method. This returns an integer defining the type. The
[XML::DOM](https://metacpan.org/pod/XML::DOM) module exports constants which
make these values easier to interpret. In this simplified example we only check
for `ELEMENT_NODE` or `TEXT_NODE`, but there are a number of other values listed
in the module’s documentation.

Having established that we are dealing with an element node, we get
the tag’s name using the `getTagName` method and a reference to its list
of attributes using the `getAttributes` method. The value returned by
getAttributes is a reference to a `NodeList` object. We can get the
number of nodes in the list with the `getLength` method and retrieve
each node in the list in turn, using the item method. For each of the
nodes returned we can get the attribute name and value using the
`getNodeName` and `getValue` methods, respectively.

Having retrieved and displayed the node attributes we can deal with
the node’s children. The `getChildNodes` method returns a NodeList of
child nodes which we can iterate over (using `getLength` and `item`
again), recursively passing each node to process_node.

If the node that we are dealing with is a text node, we get the actual text
using the `getData` method, and process the text in exactly the same way we have
before.

This description has barely scratched the surface of
[XML::DOM](https://metacpan.org/pod/XML::DOM), but it is something that you will
definitely come across if you process XML data.

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

The XML and Perl world is a very exciting place at the moment. Things are
changing all the time. The best way to keep abreast of the latest news is to
read the [Perl-XML mailing list](https://lists.perl.org/list/perl-xml.html). You
can subscribe via the web interface at:

    https://lists.perl.org/list/perl-xml.html

None of the modules that we have discussed in this chapter are
installed as part of the standard Perl installation. You will need to
get them from the CPAN and install them yourself.

Summary
-------

* XML is becoming a very common data format, particularly for exchanging data between different computer systems.

* XML documents can be either valid or well-formed. Currently, no Perl XML parser checks for validity.

* XML parsing in Perl is very easy using [XML::Parser](https://metacpan.org/pod/XML::Parser) and its various subclasses.

* [XML::Parser](https://metacpan.org/pod/XML::Parser) has a number of different styles which can be used to solve particular types of parsing tasks. If none of the standard styles suit your requirements, you can use handlers for even more control over how the parser works.

* [XML::DOM](https://metacpan.org/pod/XML::DOM) brings the industry-standard Document Object Model to the Perl/XML community.

* Specialized parsers such as [XML::RSS](https://metacpan.org/pod/XML::RSS) can be used to parse documents conforming to specific DTDs.
