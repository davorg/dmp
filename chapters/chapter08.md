Part III - Simple data parsing
==============================

As this part of the tale commences, our heroes begin to realize that
there are very good reasons for the beast to appear in more complex
forms, and they see that their current techniques will be of limited
use against these new forms. They begin to discuss more powerful
techniques to attack them.

The beast then appears in a new, hierarchical format. Luckily, our
heroes find a source of ready-made tools for defeating this form. The
beast appears once again in a more complex (and yet, in some ways,
simplified) guise and our heroes once more find ready-built tools for
defeating this form.

At the end of this part of the tale, our heroes develop techniques
which let them build their own tools to tackle the beast whenever it
appears in forms of arbitrary complexity.

Chapter 8: Complex data formats
===============================

What this chapter covers:

*  Using and processing more complex data formats

*  Limitations in data parsing

*  What are parsers and why should I use them?

*  Parsers in Perl

We have now completed our survey of the simple data formats that you
will come across. There is, however, a whole class of more complex
data formats that you will inevitably be called upon to munge at some
point. The increased flexibility that these formats give us for data
storage comes at a price, as they will take more time to process. In
this chapter we take a look at these types of data, how you discern
when to use them, and how you go about processing them.

Complex data files
------------------

A lot of the data that we have seen up to now has used one line to
represent each record in the data set. There have been exceptions;
some of the records that we saw in [Chapter 6](ch010.xhtml) used more than one row
for each record, and most of the binary data that we discussed in
[Chapter 7](ch011.xhtml) had no record-based structure at all. Even going back to
the very [first chapter](ch004.xhtml), the first sample CD data set that we saw
consisted largely of a record-based middle section, but it also has
header and footer records which would have made processing it
slightly more complex.

### Example: metadata in the CD file

Let’s take another look at that first sample data file.

	 Dave's CD Collection
	 16 Sep 1999
	 Artist
	 Title
	 Label
	 Released
	 --------------------------------------------------------
	 Bragg, Billy
	 Workers' Playtime
	 Cooking Vinyl
	 1987
	 Bragg, Billy
	 Mermaid Avenue
	 EMI
	 1998
	 Black, Mary
	 The Holy Ground
	 Grapevine
	 1993
	 Black, Mary
	 Circus
	 Grapevine
	 1996
	 Bowie, David
	 Hunky Dory
	 RCA
	 1971
	 Bowie, David
	 Earthling
	 EMI
	 1987
	 6 Records

As you can see, the data consists of three clearly delimited
sections. The main body of the file contains the meat of the report—a
list of the CDs in my record collection, giving information on
artist, title, recording label, and year of release. However, the
header and footer records also contain important data.

The header contains information about the data file as a whole,
telling us whose CD collection it is and the date on which this
snapshot is valid. It would be inappropriate to list this information
for each record in the file, so the header is a good place to put it. !!! FOOTNOTE
1 There are other places where the information could be stored. One
common solution is to store this kind of information in the name of
the data file, so that a file containing this data might be called
something like 19990916\_dave.txt. !!!

The information in the footer is a little different. In this case we
are describing the actual shape of the data rather than where (or
when) it comes from. At first glance it might seem that this
information is unnecessary, as we can find out the number of records
in the file simply by counting them as we process them. The reason
that it is useful for the file to contain an indication of the number
of records is that it acts as a simple check that the file has not
been corrupted between the time it was created and the time we
received it. By simply comparing the number of records that we
processed against the number that the file claims to contain, we can
easily tell if any went missing in transmission. !!! FOOTNOTE  2 As
with the header information, including this data within the file isn’t
the only way to do it. Another common method is to send a second file
with a similar name that contains the number of records. In the
example of my CDs, we might have another file called
19990916\_dave.rec which contains only the number 6. !!!


This then demonstrates one important reason for having more complex
data files. They allow us to include *metadata*—data about the data we
are dealing with.

#### Adding subrecords

Another good reason for using more complex formats is that you are
dealing with data that doesn’t actually fit very well into a simpler
format. Staying with the CD example, perhaps your data file needs to
contain details of the tracks on the CDs as well as the data that we
already list. At this point our line-per-record approach falls down
and we are forced to look at something more complicated. Perhaps we
will indent track records with a tab character or prefix the track
records with a + character. This would give us a file that looked
something like this (listing only the first two tracks):

	Dave's CD Collection
	16 Sep 1999
	Artist
	Title
	Label
	Released
	--------------------------------------------------------
	Bragg, Billy
	Workers' Playtime
	Cooking Vinyl
	1988
	+She's Got A New Spell
	+Must I Paint You A Picture
	Bragg, Billy
	Mermaid Avenue
	EMI
	1998
	+Walt Whitman's Niece
	+California Stars
	Black, Mary
	The Holy Ground
	Grapevine
	1993
	+Summer Sent You
	+Flesh And Blood
	Black, Mary
	Circus
	Grapevine
	1995
	+The Circus
	+In A Dream
	Bowie, David
	Hunky Dory
	RCA
	1971
	+Changes
	+Oh You Pretty Things\
	Bowie, David\
	Earthling\
	EMI\
	1997\
	+Little Wonder\
	+Looking For Satellites\
	6 Records\

### Example: reading the expanded CD file

This file is more complicated to process than just about any other
that we have seen. Here is one potential way to read the data into a
data structure.

	1: my %data;
	2:
	3: chomp($data{title} = <STDIN>);
	4: chomp($data{date} = <STDIN>);
	5: <STDIN>;
	6: my ($labels, @labels);
	7: chomp($labels = <STDIN>);
	8: @labels = split(/\s+/, $labels);
	9: <STDIN>;
	10:
	11: my $template = 'A14 A19 A15 A8';
	12:
	13: my %rec;
	14: while (<STDIN>) {
	15:
	chomp;
	16:
	17:
	last if /^\s*$/;
	18:
	19:
	if (/^\+/) {
	20:
	push @{$rec{tracks}}, substr($_, 1);
	21:
	} else {
	22:
	push @{$data{CDs}}, {%rec} if keys %rec;
	23:
	%rec = ();
	24:
	@rec{@labels} = unpack($template, $_);
	25:
	}
	26: }
	27:
	28: push @{$data{CDs}}, {%rec} if keys %rec;
	29:
	30: ($data{count}) = (<STDIN> =~ /(\d+)/);
	31:
	32: if ($data{count} == @{$data{CDs}}) {
	33:
	print "$data{count} records processed successfully\n";
	34: } else {
	35:
	warn "Expected $data{count} records but received ",
	36:
	scalar @{$data{CDs}}, "\n";
	37: }

This code is not the best way to achieve this. We’ll see a far better
way when we examine the module Parse::RecDescent in [Chapter 11](ch016.xhtml), but
in the meantime let’s take a look at the code in more detail to see
where it’s a bit kludgy.

Line 1 defines a hash where we will store the data that we read in.

Lines 3 and 4 read in the first two lines of data and store them in
$data{title} and $data{date}, respectively.

Line 5 ignores the next line in the file (which is blank).

Lines 6 to 8 get the list of labels from the header line in the file
and create an array containing the labels.

Line 9 ignores the next line in the file (which is the line of
dashes).

Line 11 creates a template for extracting the data from the CD lines
using unpack. Note that it would have been possible to create this
template automatically by calculating the lengths of the fields from
the header line.

Line 13 defines a hash that will store the details of each CD as we
read it in.

Line 14 starts a while loop which will read in all of the CD data a
line at a time.

Line 15 removes the end-of-line character from data record.

Line 17 terminates the loop when a blank line is found. This is
because there is a blank line between the CD records and the footer
data.

Line 19 checks to see if we have a CD record or a track record by
examining the first character of the data. If it is a + then we have
a track record, otherwise we assume we have a CD record.

Line 20 deals with the track record by removing the leading + and
pushing the remaining data onto a list of tracks on our current CD.

Line 22 starts to deal with a new CD. First we need to push the
previous CD record onto our list of CDs (which is stored in
$data{CDs}). Notice that we also get to this line of code at the
start of the first CD record. In this case there is no previous CD
record to store. We take care of this by only storing the record if
it contains data. Notice also that as we reuse the same %rec
variable for each CD, we make an anonymous copy of it each time.

Line 23 resets the %rec hash to be empty, and line 24 gets the data
about the new CD using unpack.

Having found the blank line at the end of the data section, we exit
from the while loop at line 26. At this point the final CD is still
stored in $rec, but hasn’t been added to $data{CDs}. We put that
right on line 28.

Line 30 grabs the number of records from the footer line in the file
and then, as a sanity check, we compare that number with the number
of records that we have processed and stored in $data{CDs}.

Figure 8.1 shows the data structure that we store the album details
in.

![Data structure modeling the complex CD data file](images/8-1-data-structure-modeling-the-complex-cd-data-file.png)

As you can see, while this approach gets the job done, it is far from
elegant. A better way to achieve this would be using a real parser.
We will take a look at simple parsers later in this chapter, but
first let’s look at more limitations of our current methods.

How not to parse HTML
---------------------

HTML and its more flexible sibling XML have become two of the most
common data formats over recent years, and there is every reason to
believe that they will continue to grow in popularity in the future.
They are so popular, in fact, that the next two chapters are dedicated
to ways of dealing with them using dedicated modules such as
HTML::Parser and XML::Parser. In this section, however, I’d like to
give you some idea of why these modules are necessary by pointing out
the limitations in the data parsing methods that we have been using up
to now.

### Removing tags from HTML

A common requirement when processing HTML is to remove the HTML tags
from the input, leaving only the plain text. We will, therefore, use
this as our example. Let’s take a simple piece of HTML and examine how
we might remove the tags. Here is the sample HTML that we will use:

	 <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
	 <html>
	 <head>
	 <title>Sample HTML</title>
	 </head>
	 <body>
	 <h1>Sample HTML</h1>
	 <p>This is a sample piece of HTML.</p>
	 <ul>
	 <li>It</li>
	 <li>Has</li>
	 <li>A</li>
	 <li>List</li>
	 </ul>
	 <p>And links to the <a href="prev.html">Previous</a> and
	 <a href="next.html">Next</a> pages.</p>
	 </body>
	 </html>

#### Example: a first attempt

Here is a first attempt to write code that removes all of the HTML
tags. I should reiterate here that all of this code is here to
demonstrate the *wrong* way to do it, so you shouldn’t be using this
code in your programs.

	 # WARNING: This code doesn't work
	 use strict;
	 while (<STDIN>) {
	   s/<.*>//;
	   print;
	 }

Nothing too difficult there. Just read in the file a line at a time
and remove everything that is between an opening < and a closing >.
Let’s see what output we get when we run that against our sample
file.

	and

That’s probably not quite what we were hoping for. So what has gone
wrong? In this case we have made a simple beginner’s mistake. By
default, Perl regular expressions are *greedy*. That is, they consume
as much of the string as possible. What this means is that where we
have a line like:

 <h1>Sample HTML</h1>

our regular expression will consume all the data between the first <
and the last >, effectively removing the whole line.

#### Example: another attempt using nongreedy regular expressions\

We can, of course, correct this by making our regular expression
nongreedy. We do this by placing a ? after the greedy part of the
regular expression (.*), meaning our code will now look like this:

	 # WARNING: This code doesn't work either
	 use strict;
	 while (<STDIN>) {
	 s/<.*?>//;
	 print;
	 }

and our output looks like this:

	Sample HTML</title>
	Sample HTML</h1>
	This is a sample piece of HTML.</p>
	It</li>
	Has</li>
	A</li>
	List</li>
	And links to the <a href="prev.html">Previous</a> and
	Next</a> pages.</p>

#### Example: adding the g modifier

The preceding output is obviously an improvement, but instead of
removing too much data we are now removing too little. We are removing
only the first tag that appears on each line. We can correct this by
adding the g modifier to our text replacement operator so that the
code looks like this:

	# WARNING: This code works, but only on very simple HTML
	use strict;

	while (<STDIN>) {
	s/<.*?>//g;
	print;
	}

And the output will look like this:

	Sample HTML




	Sample HTML
	This is a sample piece of HTML.

	  It
	  Has
	  A
	  List

	And links to the Previous and
	  Next pages.

That does look a lot better.

### Limitations of regular expressions

At this point you might be tempted to think that I was exaggerating
when I said that HTML parsing was difficult as we seem to have
achieved it in four lines of Perl. The problem is that while we have
successfully parsed this particular piece of HTML, we are still a
long way from dealing with the problem in general. The HTML we have
dealt with is very simple and almost certainly any real world HTML
will be far more complex.

The first assumption that we have made about HTML is that all tags
start and finish on the same line. You only need to look at a few
web pages to see how optimistic that is. Many HTML tags have a number
of attributes and can be spread out over a number of lines. Take this
tag for example:

	<img src="http://www.mag-sol.com/images/logo.gif"
	height="25" width="100"
	alt="Magnum Solutions Ltd.">

Currently our program will leave this tag untouched. There are, of
course, ways around this. We could read the whole HTML file into a
single scalar variable and run our text replacement on that variable.
!!! FOOTNOTE  3 We would have to add the s modifier to the operator,
to get the . to match newline characters.!!! The downside of this
approach is that, while it is not a problem for a small file like our
example, there may be good reasons for not reading a larger document
into memory all at once.

We have seen a number of reasons why our approach to parsing HTML is
flawed. We can provide workarounds for all of the problems we have
come across so far, but the next problem is a little more serious.
Basically, our current methods don’t understand the structure of an
HTML document and don’t know that different rules apply at different
times. Take a look at the following piece of valid HTML:

	<img src="/images/prev.gif" alt="<-">
	<img src="/images/next.gif" alt="->">

In this example, the web page has graphics that link to the previous
and next pages. In case the user has a text-only browser or has
images switched off, the author has provided alt attributes which can
be displayed instead of the images. Unfortunately, in the process
he has completely broken our basic HTML parsing routine. The > symbol
in the second alt attribute will be interpreted by our code as the
end of the img tag. Our code doesn’t know that it should ignore >
symbols if they appear in quotes. Building regular expressions to
deal with this is possible, but it will make your code much more
complex and just when you’ve added that you’ll find another
complication that you’ll need to deal with.

The point is that while you can solve all of these problems, there
are always new problems around the corner and there comes a point
when you have to stop looking for new problems to address and put
the code into use. If you can be sure of the format of your HTML, you
can write code which processes the subset of HTML that you know you
will be dealing with, but the only way to deal with all HTML is to
use an HTML parser. We’ll see a lot more about parsing HTML (and also
XML) in the following chapters.

Parsers
-------

We’ve seen in the previous section that for certain types of data,
our usual regular expression-based approach is not guaranteed to
work. We must therefore find a new approach. This will involve the
use of parlance.

### An introduction to parsers

As I have hinted throughout this chapter, the solution to all of
these problems is to use a parser. A *parser* is a piece of software
that takes a piece of input data and looks for recognizable patterns
within it. This is, of course, what all of our parsing routines have
been doing, but we are now looking at a far more mathematically
rigorous way of splitting up our input data.

Before I go into the details of parsing, I should point out that this
is a very complex field and there is a lot of very specific jargon
which I cannot address here in detail. If you find your interest
piqued by this high-level summary you might want to look at the books
recommended at the end of this chapter.

#### An introduction to parsing jargon

I said that parsers look for recognizable patterns in the input data.
The first question, therefore, should be: how do parsers know what
patterns to recognize? Any parser works on a grammar that defines the
allowable words in the input data and their allowed relationships with
each other. Although I say words, obviously in the kinds of data that
we are dealing with these words can, in fact, be any string of
characters. In parsing parlance they are more accurately known as
*tokens*.

The grammar therefore defines the tokens that the input data should
contain and how they should be related. It does this by defining a
number of rules. A rule has a name and a definition. The definition
contains the list of items that can be used to match the rule. These
items can either be *subrules* or a definition of the actual text that
makes up the token. This may all become a bit clearer if we look at a
simple grammar. Figure 8.2 shows a grammar which defines a particular
type of simple English sentence.

![Simple grammar](images/8-2-simple-grammar.png)

This grammar says that a sentence is made up of a subject followed
by a verb and an object. The verb is a *terminal* (in capital
letters) which means that no further definition is required. Both
the subject and the object are noun phrases and a noun phrase is
defined as either a pronoun, a proper noun, or an article followed
by a noun. In the last rule, pronouns, proper nouns, articles, and
nouns are all terminals. Notice that the vertical bars in the
definition of a noun_phrase indicate alternatives, *i.e.*, a noun
phrase rule can be matched by one of three different forms. Each of
these alternatives is called a *production*.

#### Matching the grammar against input data\

Having defined the grammar, the parser now has to match the input data
against the grammar. First it will break up the input text into
tokens. A separate process called a lexer often does this. The parser
then examines the stream of tokens and compares it with the grammar.
There are two different ways that a parser will attempt this.

##### Bottom-up parsers

An LR (scan left, expand rightmost subrule) parser will work like a
finite state machine. Starting in a valid start state, the parser will
compare the next token with the grammar to see if it matches a
possible successor state. If so, it moves to the successor state and
starts the process again. Figure 8.3 shows how this process works for
our simple grammar. The parser begins at the Start node and takes the
first token from the input stream. The parser is allowed to move to
any successor state which is linked to its current state by an arrow
(but only in the direction of the arrow). If the parser gets to the
end of the stream of tokens and is at the Finish node, then the parse
was successful; otherwise the parse has failed. If at any point the
parser finds a token which does not match the successor states of its
current state, then the parse also fails.

![LR Parser](images/8-3-lr-parser.png)

At any point, if the finite state machine cannot find a matching
successor state, it will go back a state and try an alternative
route. If it gets to the end of the input data and finds itself in a
valid end state, then the parse has succeeded; if not it has failed.
This type of parser is also known as a *bottom-up* parser.

##### Top-down parsers

An LL (scan left, expand leftmost subrule) parser will start by trying
to match the highest level rule first (the sentence rule in our
example). To do that, it needs to match the subrules within the
top-level rule, so it would start to match the subject rule and so on
down the grammar. Once it has matched all of the terminals in a rule,
it knows that has matched that rule. Figure 8.4 shows the route that
an LL parser would take when trying to match an input stream against
out sample grammar.

![LL Parser](images/8-4-ll-parser.png)

Matching all of the subrules in a production means that it has
matched the production and, therefore, the rule that the production
is part of. If the parser matches all of the subrules and terminals
in one of the productions of the top-level rule, then the parse has
succeeded. If the parser runs out of productions to try before
matching the top-level rule, then the parse has failed. For obvious
reasons, this type of parser is also known as a *top-down* parser.

### Parsers in Perl

Parsers in Perl come in two types: prebuilt parsers such as
HTML::Parser and XML::Parser, which are designed to parse a particular
type of data, and modules such as Parse::Yapp and Parse::RecDescent
which allow you to create your own parsers from a grammar which you
have defined. In the next two chapters we will take a longer look at
the HTML::Parser and XML::Parser families of modules; and in [Chapter
11](ch016.xhtml) we will examine Parse::RecDescent, in detail,
which is the most flexible tool for creating your own parsers in Perl.

Further information
-------------------

More information about parsing HTML can be found in the [next chapter](ch014.xhtml)
of this book. For additional information about parsing in general:
*Compilers: Principles, Techniques and Tools* (a.k.a. “The Dragon
Book”) by Aho, Sethi, and Ullman (Addison-Wesley) is the definitive
guide to the field; *The Art of Compiler Design* by Pittman and Peters
(Prentice Hall) is, however, a far gentler introduction.

Summary
-------

*  There are often very good reasons for having data that is not strictly in a record-based format. These reasons can include:

*  Including metadata about the data file.

*  Including subsidiary records.

*  When parsing hierarchical data such as HTML our usual regular expression-based approach can break down and we need to look for more powerful techniques.

*  Parsers work by examining a string of tokens to see if they match the rules defined in a grammar.

*  Parsers can either be bottom-up (scan left, expand rightmost subrule) or top-down (scan left, expand leftmost subrule).
