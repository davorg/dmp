Foreword
========

Perl is something of a weekend warrior. Outside of business hours
you’ll find it indulging in all kinds of extreme sports: writing
haiku; driving GUIs; reviving Lisp, Prolog, Forth, Latin, and other
dead languages; playing psychologist; shovelling MUDs; inflecting
English; controlling neural nets; bringing you the weather; playing
with Lego; even running quantum computations.

But that’s not its day job.

Nine-to-five it earns its keep far more prosaically: storing information
in databases, extracting it from files, reorganizing rows and columns,
converting to and from bizarre formats, summarizing documents, tracking
data in real time, creating statistics, doing back-up and recovery,
merging and splitting data streams, logging and checkpointing computations.

In other words, munging data. It’s a dirty job, but *someone* has to do
it.

If that someone is you, you’re definitely holding the right book. In
the following pages, Dave will show you dozens of useful ways to get those
everyday data manipulation chores done better, faster, and more reliably.
Whether you deal with fixed-format data, or binary, or SQL databases, or
CSV, or HTML/XML, or some bizarre proprietary format that was obviously
made up on a drunken bet, there’s help right here.

Perl is so good for the extreme stuff, that we sometimes forget how
powerful it is for mundane data manipulation as well. As this book so ably
demonstrates, in addition to the hundreds of esoteric tools it offers,
our favourite Swiss Army Chainsaw also sports a set of simple blades that
are ideal for slicing and dicing ordinary data.

Now *that’s* a knife!

DAMIAN CONWAY

Preface
=======

Over the last five years there has been an explosion of interest in
Perl. This is largely because of the huge boost that Perl received when
it was adopted as the de facto language for creating content on the
World Wide Web. Perl’s powerful text manipulation facilities made it an
obvious choice for writing Common Gateway Interface (CGI) scripts. In
the wake of the web’s popularity, Perl has become one of the hottest
programming languages currently in use.

Unfortunately, a side effect of this association with CGI programming
has been the popular misconception that this is Perl’s sole function. Some
people even believe that Perl was designed for use in CGI programming.
This is clearly wrong as Perl was, in fact, written long before the
design of the CGI protocol.

This book, then, is not about writing CGI scripts, but about another of
the computing tasks for which Perl is particularly well suited—data
munging.

Data munging encompasses all of those boring, everyday tasks to which
most programmers devote a good deal of their time - the tasks of converting
data from one format into another. This comes close to being a definitive
statement of what programming is: taking input data, processing (or
“munging”) it, and producing output data. This is what most programmers
do most of the time.

Perl is particularly good at these kinds of tasks. It helps programmers
write data conversion programs quickly. In fact, the same characteristics
that make Perl ideal for CGI programming also make it ideal for data
munging. (CGI programs are really data munging programs in flashy disguise.)

In keeping with the Perl community slogan, “There’s more than one way
to do  it,” this book examines a number of ways of dealing with various
types of data. Hopefully, this book will provide some new “ways to do it”
that will make your programming life more productive and more enjoyable.

Another Perl community slogan is, “Perl makes easy jobs easy and hard
jobs possible.” It is my hope that by the time you have reached the end
of this book, you will see that “Perl makes fun jobs fun and boring jobs
bearable.”

Intended audience
-----------------

This book is aimed primarily at programmers who munge data as a regular
part of their job and who want to write more efficient data-munging
code. I will discuss techniques for data munging, introducing new
techniques, as well as novel uses for familiar methods. While some
approaches can be applied using any language, I use Perl here to
demonstrate the ease of applying these techniques in this versatile
language. In this way I hope to persuade data mungers that Perl is a
flexible and vital tool for their day-to-day work.

Throughout the book, I assume a rudimentary knowledge of Perl on the
part of the reader. Anyone who has read and understood an introductory
Perl text should have no problem following the code here, but for the
benefit of readers brand new to Perl, I’ve included both my
suggestions for Perl primers (see [Chapter 1](ch004.html)) as
well as a brief introduction to Perl (see [Appendix
B](ch019.html)).

About this book
---------------

The book begins by addressing introductory and general topics, before
gradually exploring more complex types of data munging.

[PART I](ch003.xhtml) sets the scene for the rest of the book.

*[Chapter 1](ch004.xhtml)* introduces data munging and Perl. I discuss why Perl is
particularly  well suited to data munging and survey the types of data
that you might meet, along with the mechanisms for receiving and sending
data.

*[Chapter 2](ch005.xhtml)* contains general methods that can be used to make data
munging programs more efficient. A particularly important part of this
chapter is the discussion of the UNIX filter model for program input
and output.

*[Chapter 3](ch006.xhtml)* discusses a number of Perl idioms that will be useful across
a number of different data munging tasks, including sorting data and
accessing databases.

*[Chapter 4](ch007.xhtml)* introduces Perl’s pattern-matching facilities, a fundamental
part of many data munging programs.

[PART II](ch008.xhtml) begins our survey of data formats by looking at unstructured
and record-structured data.

*[Chapter 5](ch009.xhtml)* surveys unstructured data. We concentrate on processing
free text and producing statistics from a text file. We also go over
a couple of techniques for converting numbers between formats.

*[Chapter 6](ch010.xhtml)* considers record-oriented data. We look at reading and
writing data one record at a time and consider the best ways to split
records into individual fields. In this chapter, we also take a closer
glance at one common record-oriented file format: comma-separated
values (CSV) files, view more complex record types, and examine Perl’s
data handling facilities.

*[Chapter 7](ch011.xhtml)* discusses fixed-width and binary data. We compare several
techniques for splitting apart fixed-width records and for writing
results into a fixed-width format. Then, using the example of a couple
of popular binary file formats, we examine binary data.

[PART III](ch012.xhtml) moves beyond the limits of the simple data formats into the
realms of hierarchical data structures and parsers.

*[Chapter 8](ch013.xhtml)* investigates the limitations of the data formats that we
have seen previously and suggests good reasons for wanting more complex
formats. We then see how the methods we have used so far start to break
down on more complex data like HTML. We also take a brief look at an
introduction to parsing theory.

*[Chapter 9](ch014.xhtml)* explores how to extract useful information from documents
marked up with HTML. We cover a number of HTML parsing tools available for
Perl and discuss their suitability to particular tasks.

*[Chapter 10](ch015.xhtml)* discusses XML. First, we consider the limitations of HTML
and the advantages of XML. Then, we look at XML parsers available for
use with Perl.

*[Chapter 11](ch016.xhtml)* demonstrates how to write parsers for your own data
structures using a parser-building tool available for Perl.

PART IV concludes our tour with a brief review as well as suggestions
for further study.

*[Appendix A](ch018.xhtml)* is a guide to many of the Perl modules covered in the
book.

*[Appendix B](ch019.xhtml)* provides a rudimentary introduction to Perl.

Typographical conventions
-------------------------

The following conventions are used in the book:

* Technical terms are introduced in an *italic font*.
* The names of functions, files, and modules appear in a `fixed-width
font`.
* All code examples are also in a `fixed-width font`.
* Program output is in a **`bold fixed-width font`**.
* The following conventions are followed in diagrams of data structures:
    * An array is shown as a rectangle. Each row within the rectangle
represents one element of the array. The element index is shown on the
left of the row, and the element value is shown on the right of the row.
    * A hash is shown as a rounded rectangle. Each row within the rectangle
represents a key/value pair. The key is shown on the left of the row, and
the value is shown on the right of the row.
    * A reference is shown as a black disk with an arrow pointing to the
referenced variable. The type of the reference appears to the left of the
disk.

Source code downloads
---------------------

All source code for the examples presented in this book is available to
purchasers from the Manning web site. The URL [www.manning.com/cross/](www.manning.com/cross/)
includes a link to the source code files.

Author Online
-------------

Purchase of *Data Munging with Perl* includes free access to a private
Web forum run by Manning Publications where you can make comments about
the book, ask technical questions, and receive help from the author and
from other users. To access the forum and subscribe to it, point your web
browser to [www.manning.com/cross/](www.manning.com/cross/). This page provides information on how
to get on the forum once you are registered, what kind of help is
available, and the rules of conduct on the forum.

Manning’s commitment to our readers is to provide a venue where a
meaningful dialog between individual readers and between readers and the
author can take place. It is not a commitment to any specific amount of
participation on the part of the author, whose contribution to the AO
remains voluntary (and unpaid).

We suggest you try asking the author some challenging questions lest his
interest stray!

The Author Online forum and the archives of previous discussions will
be accessible from the publisher’s website as long as the book is in print.

Acknowledgments
---------------

My heartfelt thanks to the people who have made this book possible
(and, who, for reasons I’ll never understand, don’t insist on having
their names appear on the cover).

Larry Wall designed and wrote Perl, and without him this book would
have been very short.

Marjan Bace and his staff at Manning must have wondered at times if
they would ever get a finished book out of me. I’d like to specifically
mention Ted Kennedy for organizing the review process; Mary Piergies
for steering the manuscript through production; Syd Brown for answering
my technical questions; Sharon Mullins and Lianna Wlasiuk for editing;
Dottie Marsico for typesetting the manuscript and turning my original
diagrams into something understandable; and Elizabeth Martin for copyediting.

I was lucky enough to have a number of the brightest minds in the Perl
community review my manuscript. Without these people the book would have
been riddled with errors, so I owe a great debt of thanks to Adam Turoff,
David Adler, Greg McCarroll, D.J. Adams, Leon Brocard, Andrew Johnson,
Mike Stok, Richard Wherry, Andy Jones, Sterling Hughes, David Cantrell,
Jo Walsh, John Wiegley, Eric Winter, and George Entenman.

Other Perl people were involved (either knowingly or unknowingly) in
conversations that inspired sections of the book. Many members of the
London Perl Mongers mailing list have contributed in some way, as have
inhabitants of the Perl Monks Monastery. I’d particularly like to thank
Robin Houston, Marcel Grünauer, Richard Clamp, Rob Partington, and Ann
Barcomb.

Thank you to Sean Burke for correcting many technical inaccuracies and
also improving my prose considerably.

Many thanks to Damian Conway for reading through the manuscript at the
last minute and writing the foreword.

A project of this size can’t be undertaken without substantial support
from friends and family. I must thank Jules and Crispin Leyser for
ensuring that I took enough time off from the book to enjoy myself
drinking beer and playing poker or Perudo.

Thank you, Jordan, for not complaining too much when I was too busy to
fix your computer.

And lastly, thanks and love to Gill without whose support,
encouragement, and love I would never have got to the end of this. I
know that at times over the last year she must have wondered if she
still had a husband, but I can only apologize (again) and promise that
she’ll see much more of me now that the book is finished.

About the cover illustration
----------------------------

The important-looking man on the cover of *Data Munging with Perl* is a
Turkish First Secretary of State. While the exact meaning of his title
is for us shrouded in historical fog, there is no doubt that we are
facing a man of prestige and power. The illustration is taken from a
Spanish compendium of regional dress customs first published in Madrid
in 1799. The book’s title page informs us:

> Coleccion general de los Trages que usan actualmente todas las Nacionas
> del Mundo desubierto, dibujados y grabados con la mayor exactitud por
> R.M.V.A.R. Obra muy util y en special para los que tienen la del viajeroi
> universal

Which we loosely translate as:

> General Collection of Costumes currently used in the Nations of the
> Known World, designed and printed with great exactitude by R.M.V.A.R. This
> work is very useful especially for those who hold themselves to be universal
> travelers

Although nothing is known of the designers, engravers and artists who
colored this illustration by hand, the “exactitude” of their execution is
evident in this drawing. The figure on the cover is a “Res Efendi,” a
Turkish government official which the Madrid editor renders as “Primer
Secretario di Estado.” The Res Efendi is just one of a colorful variety
of figures in this collection which reminds us vividly of how distant
and isolated from each other the world’s towns and regions were
just 200 years ago. Dress codes have changed since then and the diversity
by region, so rich at the time, has faded away. It is now often hard to
tell the inhabitant of one continent from another. Perhaps we have traded
a cultural and visual diversity for a more varied personal life — certainly
a more varied and interesting world of technology.

At a time when it can be hard to tell one computer book from another,
Manning celebrates the inventiveness and initiative of the computer business
with book covers based on the rich diversity of regional life of two centuries
ago—brought back to life by the picture from this collection.
