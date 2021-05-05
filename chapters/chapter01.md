Part I - Foundations
====================

In which our heroes learn a great deal about the background of the
data munging beast in all its forms and habitats. Fortunately, they
are also told of the great power of the mystical Perl which can be used
to tame the savage beast.

Our heroes are then taught a number of techniques for fighting the
beast *without* using the Perl. These techniques are useful when
fighting with any weapon, and once learned, can be combined with the
power of the Perl to make them even more effective.

Later, our heroes are introduced to additional techniques for using
the Perl — all of which prove useful as their journey continues.

Chapter 1: Data, data munging, and Perl
=======================================

What this chapter covers:

* The process of munging data
* Sources and sinks of data
* Forms data takes
* Perl and why it is perfect for data munging

## What is data munging?

> **munge** (muhnj) vt. **1.** [derogatory] To imperfectly transform
> information. **2.** A comprehensive rewrite of a routine, a data
> structure, or the whole program. **3.** To modify data in some way
> the speaker doesn’t need to go into right now or cannot describe
> succinctly (compare mumble).
> [The Jargon File](http://www.tuxedo.org/\~esr/jargon/html/entry/munge.html
)

Data munging is all about taking data that is in one format and
converting it into another. You will often hear the term being used
when the speaker doesn’t really know exactly what needs to be done
to the data.

> We’ll take the data that’s exported by this system, munge it around a
> bit, and  import it into that system.

When you think about it, this is a fundamental part of what many (if
not most) computer systems do all day. Examples of data munging include:

* The payroll process that takes your pay rate and the hours you work and
creates a monthly payslip

* The process that iterates across census returns to produce statistics
about the population

* A process that examines a database of sports scores and produces a
league table

* A publisher who needs to convert manuscripts between many different
text formats

### Data munging processes

More specifically, data munging consists of a number of processes that
are applied to an initial data set to convert it into a different, but
related data set. These processes will fall into a number of categories:
recognition, parsing, filtering, and transformation.

### Example data: the CD file

To discuss these processes, let’s assume that we have a text file
containing a description of my CD collection. For each CD, we’ll list
the artist, title, recording label, and year of release. Additionally
the file will contain information on the date on which it was generated
and the number of records in the file. Figure 1.1 shows what this file
looks like with the various parts labeled.

![Sample data file](images/1-1-sample-data-file.png)

Each row of data in the file (i.e., the information about one CD) is
called a data *record*. Each individual item of data (e.g., the CD
title or year of release) is called a data *field*. In addition to
records and fields, the data file might contain additional information
that is held in headers or footers. In this example the header contains
a description of the data, followed by a header row which describes the
meaning of each individual data field. The footer contains the number
of records in the file. This can be useful to ensure that we have
processed (or even received) the whole file.

We will return to this example throughout the book to demonstrate data
munging techniques.

### Data recognition

You won’t be able to do very much with this data unless you can
recognize what data you have. Data recognition is about examining
your source data and working out which parts of the data are of
interest to you. More specifically, it is about a computer program
examining your source data and comparing what it finds against
pre-defined patterns which allow it to determine which parts of the
data represent the data items that are of interest.

In our CD example there is a lot of data and the format varies within
different parts of the file. Depending on what we need to do with the
data, the header and footer lines may be of no interest to us. On the
other hand, if we just want to report that on Sept. 16, 1999 I owned
six CDs, then all the data we are interested in is in the header and
footer records and we don’t need to examine the actual data records
in any detail.

An important part of recognizing data is realizing what *context* the
data is found in. For example, data items that are in header and
footer records will have to be processed completely differently from
data items which are in the body of the data.

It is therefore very important to understand what our input data looks
like and what we need to do with it.

### Data parsing

Having recognized your data you need to be able to do something with
it. Data parsing is about taking your source data and storing it in data
structures that make it easier for you to carry out the rest of the
required processes.

If we are parsing our CD file, we will presumably be storing details of
each CD in a data structure. Each CD may well be an element in a list
structure and perhaps the header and footer information will be in
other variables. Parsing will be the process that takes the text file
and puts the useful data into variables that are accessible from
within our program.

As with data recognition, it is far easier to parse data if you know
what you are going to do with it, as this will affect the kinds of data
structures that you use.

In practice, many data munging programs are written so that the data
recognition and data parsing phases are combined.

### Data filtering

It is quite possible that your source data contains too much information.
You will therefore have to reduce the amount of data in the data set.
This can be achieved in a number of ways.

* *You can reduce the number of records returned.* For example, you could
list only CDs by David Bowie or only CDs that were released in the 1990s.

* *You can reduce the number of fields returned.* For example, you could
list only the artist, title, and year of release of all of the CDs.

* *You can summarize the data in a variety of ways.* For example, you
could list only the total number of CDs for each artist or list the
number of CDs released in a certain year.

* *You can perform a combination of these processes.* For example, you
could list the number of CDs by Billy Bragg.

### Data transformation

Having recognized, parsed, and filtered our data, it is very likely
that we need to transform it before we have finished with it. This
transformation can take a variety of forms.

* *Changing the value of a data field* — For example, a customer number
needs to be converted to a different identifier in order for the data to
be used in a different system.

* *Changing the format of the data record* — For example, in the input
record, the fields were separated by commas, but in the output record they
need to be separated by tab characters.

* *Combining data fields* — In our CD file example, perhaps we want to make
the name of the artist more accessible by taking the “surname, forename”
format that we have and converting it to “forename surname.”

### Why is data munging important?

As I mentioned previously, data munging is at the heart of what most
computer systems do. Just about any computer task can be seen as a
number of data munging tasks. Twenty years ago, before everyone had
a PC on a desk, the computing department of a company would have been
known as the Data Processing department as that was their role — they
processed data. Now, of course, we all deal with an Information Systems
or Information Technology department and the job has more to do with
keeping our PCs working than actually doing any data processing. All that
has happened, however, is that the data processing is now being carried
out by everyone, rather than a small group of computer programmers and
operators.

### Accessing corporate data repositories

Large computer systems still exist. Not many larger companies run their
payroll system on a PC and most companies will have at least one
database system which contains details of clients, products, suppliers,
and employees. A common task for many office workers is to input data
into these corporate data repositories or to extract data from them.
Often the data to be loaded onto the system comes in the form of
a spreadsheet or a comma-separated text file. Often the data extracted
will go into another spreadsheet where it will be turned into tables
of data or graphs.

### Transferring data between multiple systems

It is obviously convenient for any organization if its data is held in
one format in one place. Every time you duplicate a data item, you
increase the likelihood that the two copies can get out of step with
each other. As part of any database design project, the designers will
go through a process known as normalization which ensures that data is
held in the most efficient way possible.

It is equally obvious that if data is held in only one format, then it
will not be in the most appropriate format for all of the systems that
need to access that data. While this format may not be particularly
convenient for any individual system, it should be chosen to allow
maximum flexibility and ease of processing to simplify conversion into
other formats. In order to be useful to all of the people who want
to make use of the data, it will need to be transformed in various ways
as it moves from one system to the next.

This is where data munging comes in. It lives in the interstices
between computer systems, ensuring that data produced by one system can
be used by another.

### Real-world data munging examples

Let’s look at a couple of simple examples where data munging can be
used. These are simplified accounts of tasks that I carried out for large
investment banks in the city of London.

#### Loading multiple data formats into a single database

In the first of these examples, a bank was looking to purchase some company
accounting data to drive its equities research department. In any large
bank the equity research department is full of people who build complex
financial models of company performance in order to try to predict future
performance, and hence share price. They can then recommend shares to
their clients who buy them and (hopefully) get a lot richer in the process.

This particular bank needed more data to use in its existing database
of company accounting data. There are many companies that supply this data
electronically and a short list of three suppliers had been drawn up and a
sample data set had been received from each. My task was to load these three
data sets, in turn, onto the existing database.

The three sets of data came in different formats. I therefore decided
to design a canonical file format and write a Perl script that would load that
format onto the database. I then wrote three other Perl scripts (one for each
input file) which read the different input files and wrote a file in my
standard format. In this case I was reading from a number of sources and
writing to one place.

#### Sharing data using a standard data format

In the second example I was working on a trading system which needed
to send details of trades to various other systems. Once more, the
data was stored in a relational database. In this case the bank had
made all interaction between systems much easier by designing an XML
file format for data interchange (we'll talk about DTDs in [Chapter
10](ch015.xhtml)). Therefore, all we needed to do was to extract our data, create
the necessary XML file, and send it on to the systems that required
it. By defining a standard data format, the bank ensured that all of
its systems would only need to read or write one type of file, thereby
saving a large amount of development time.

Where does data come from? Where does it go?
--------------------------------------------

As we saw in the previous section, the point of data munging is to take
data in one format, carry out various transformations on it, and write it
out in another format. Let’s take a closer look at where the data might come
from and where it might go.

First a bit of terminology. The place that you receive data from is
known as your *data source*. The place where you send data to is known as
your *data sink*.

Sources and sinks can take a number of different forms. Some of the most
common ones that you will come across are:

* Data files
* Databases
* Data pipes

Let’s look at these data sources and sinks in more detail.

### Data files

Probably the most common way to transfer data between systems is in a
file. One application writes a file. This file is then transferred to a
place where your data munging process can pick it up. Your process opens
the file, reads in the data, and writes a new file containing the transformed
data. This new file is then used as the input to another application
elsewhere.

Data files are used because they represent the lowest common denominator
between computer systems. Just about every computer system has the concept of
a disk file. The exact format of the file will vary from system to system
(even a plain ASCII text file has slightly different representations under
UNIX and Windows) but handling that is, after all, part of the job of the
data munger.

#### File transfer methods

Transferring files between different systems is also something that is
usually very easy to achieve. Many computer systems implement a version
of the *File Transfer Protocol* (FTP) which can be used to copy files
between two systems that are connected by a network. A more sophisticated
system is the *Network File System* (NFS) protocol, in which file systems
from one computer can be viewed as apparently local files systems on another
computer. Other common methods of transferring files are by using removable
media (CD-ROMs, floppy disks, or tapes) or even as a MIME attachment to an
email message.

#### Ensuring that file transfers are complete

One difficulty to overcome with file transfer is the problem of knowing if
a file is complete. You may have a process that sits on one system,
monitoring a file system where your source file will be written by another
process. Under most operating systems the file will appear as soon as the
source process begins to write it. Your process shouldn’t start to read the
file until it has all been transferred. In some cases, people write complex
systems which monitor the size of the file and trigger the reading process
only once the file has stopped growing. Another common solution is for the
writing process to write another small flag file once the main file is
complete and for the reading process to check for the existence of this
flag file. In most cases a much simpler solution is also the best—simply
write the file under a different name and only rename it to the expected
name once it is complete.

Data files are most useful when there are discrete sets of data that you want
to process in one chunk. This might be a summary of banking transactions
sent to an accounting system at the end of the day. In a situation where a
constant flow of data is required, one of the other methods discussed below
might be more appropriate.

### Databases

Databases are becoming almost as ubiquitous as data files. Of course, the
term “database” means vastly differing things to different people. Some
people who are used to a Windows environment might think of dBase or some
similar nonrelational database system. UNIX users might think of a set of
DBM files. Hopefully, most people will think of a relational database
management system (RDBMS), whether it is a single-user product like Microsoft
Access or Sybase Adaptive Server Anywhere, or a full multi-user product such
as Oracle or Sybase Adaptive Server Enterprise.

#### Imposing structure on data

Databases have advantages over data files in that they impose structure on
your data. A database designer will have defined a *database schema*, which
defines the shape and type of all of your data objects. It will define, for
example, exactly which data items are stored for each customer in the
database, which ones are optional and which ones are mandatory. Many
database systems also allow you to define relationships between data objects
(for example, “each order must contain a customer identifier which must
relate to an existing customer”). Modern databases also contain executable
code which can define some of your business logic (for example, “when the
status of an order is changed to ‘delivered,’ automatically create an invoice
object relating to that order”).

Of course, all of these benefits come at a price. Manipulating data within a
database is potentially slower than equivalent operations on data files.
You may also need to invest in new hardware as some larger database systems
like to have their own CPU (or CPUs) to run on. Nevertheless, most
organizations are prepared to pay this price for the extra flexibility that
they get from a database.

#### Communicating with databases

Most modern databases use a dialect of Structured Query Language (SQL) for
all of their data manipulation. It is therefore very likely that if your data
source or sink is an RDBMS that you will be communicating with it using SQL.
Each vendor’s RDBMS has its own proprietary interface to get SQL queries into
the database and data back into your program, but Perl now has a
vendor-independent database interface (called DBI) which makes it much easier
to switch processing between different databases (as long as you don’t make
any use of vendor-specific features).

### Data pipes

If you need to constantly monitor data that is being produced by a system and
transform it so it can be used by another system (perhaps a system that is
monitoring a real-time stock prices feed), then you should look at using a data
pipe. In this system an application writes directly to the standard input
of your program. Your program needs to read data from its input, deal with it
(by munging it and writing it somewhere), and then go back to read more input.
You can also create a data pipe (or continue an existing one) by writing your
munged data to your standard output, hoping that the next link in the pipe
will pick it up from there.

We will look at this concept in more detail when discussing the UNIX “filter”
model in [Chapter 2](ch005.xhtml).

### Other sources/sinks

There are a number of other types of sources and sinks. Here, briefly, are a
few more that you might come across. In each of these examples we talk about
receiving data from a source, but the concepts apply equally well to sending
data to a sink.

* *Named Pipe* — This is a feature of many UNIX-like operating systems. One
process prepares to write data to a named pipe which, to other processes,
looks like a file. The writing process waits until another process tries to
read from the file. At that point it writes a chunk of data to the named
pipe, which the reading process sees as the contents of the file. This is
useful if the reading process has been written to expect a file, but you
want to write constantly changing data.

* *TCP/IP Socket* — This is a good way to send a stream of data between two
computers that are on the same network. The two systems define a TCP/IP
port number through which they will communicate. The data munging process
then sets itself up as a TCP/IP server and listens for connections on the
right port. When the source has data to send, it instigates a connection on
the port. Some kind of (application-defined) handshaking then takes place,
followed by the source sending the data across to the waiting server.

* *HTTP* —This method is becoming more common. If both programs have access
to the Internet, they can be on opposite sides of the world and can still
talk to each other. The source simply writes the data to a file somewhere on
the publicly accessible Internet. The data munging program uses HTTP to send
a request for the file to the source’s web server and, in response, the web
server sends the file. The file could be an HTML file, but it could just as
easily be in any other format. HTTP also has some basic authentication
facilities built into it, so it is feasible to protect files to which you
don’t want the public to have access.

What forms does data take?
--------------------------

Data comes in many different formats. We will be examining many formats in
more detail later in the book, but for now we’ll take a brief survey of the
most popular ones.

### Unstructured data

While there is a great deal of unstructured data in the world, it is unlikely
that you will come across very much of it, because the job of data munging is
to convert data from one structure to another. It is very difficult for a
computer program to impose structure on data that isn’t already structured
in some way. Of course, one common data munging task is to take data with no
apparent structure and bring out the structure that was hiding deep within it.

The best example of unstructured data is plain text. Other than separating
text into individual lines and words and producing statistics, it is difficult
to do much useful work with this kind of data.

Nonetheless, we will examine unstructured data in [Chapter 5](ch009.xhtml). This is largely
because it will give us the chance to discuss some general mechanisms, such
as reading and writing files, before moving on to better structured data.

### Record-oriented data

Most of the simple data that you will come across will be record-oriented.
That is, the data source will consist of a number of records, each of which
can be processed separately from its siblings. Records can be separated from
each other in a number of ways. The most common way is for each line in a
text file to represent one record,[5] but it is also possible that a blank
line or a well-defined series of characters separates records. There is, of
course, potential for confusion over exactly what constitutes a line, but we’ll
discuss that in more detail later.

Within each record, there will probably be fields, which represent the various
data items of the record. These will also be denoted in several different ways.
There may well be a particular character between different fields (often a
comma or a tab), but it is also possible that a record will be padded with
spaces or zeroes to ensure that it is always a given number of characters
in width.

We will look at record-oriented data in [Chapter 6](ch010.xhtml).

### Hierarchical data

This is an area that will be growing in importance in the coming years. The
best example of hierarchical data is the *Standardized General Mark-up
Language* (SGML), and its two better known offspring, the *Hypertext Mark-up
Language* (HTML) and the *Extensible Mark-up Language* (XML). In these systems,
each data item is surrounded by tags which denote its position in the
hierarchy of the data. A data item is contained by its parent and contains
its own children. At this point, the record-at-a-time processing methods
that we will have been using on simpler data types no longer work and we
will be forced to find more powerful tools.

This family metaphor can, of course, be taken further. Two nodes which
have the same parent are known as *sibling* nodes, although I’ve never yet
heard two nodes with the same grandparents described as *cousins*.
We will look at hierarchical data (specifically HTML and XML) in [Chapters 9](ch014.xhtml)
and [10](ch015.xhtml).


### Binary data

Finally, there is binary data. This is data that you cannot successfully use
without software which has been specially designed to handle it. Without
having access to an explanation of the structure of a binary data file, it
is very difficult to make any sense of it. We will take a look at some
publicly available binary file formats and see how to get some meaningful
data out of them.

We will look at binary data in [Chapter 7](ch011.xhtml).

What is Perl?
-------------

Perl is a computer programming language that has been in use since 1987. It
was initially developed for use on the UNIX operating system, but it has
since been ported to more operating systems than just about any other
programming language (with the possible exception of C).

Perl was written by Larry Wall to solve a particular problem, but instead of
writing something that would just solve the question at hand, Wall wrote a
general tool that he could use to solve other problems later.

What he came up with was just about the most useful data processing tool that
anyone has created.

What makes Perl different from many other computer languages is that Wall has
a background in linguistics and brought a lot of this knowledge to bear in the
design of Perl’s syntax. This means that a lot of the time you can say things
in a more natural way in Perl and the code will mean what you expect it to
mean.

For example, most programming languages have an if statement which you can
use to write something like this:

    if (condition) {
      do_something();
    }

but what happens if you want to do some special processing only if the
condition is false? Of course you can often write something like:

    if (not condition) {
      do_something();
    }

but it’s already starting to look a bit unwieldy. In Perl you can write:

    unless (condition) {
      do_something();
    }

which reads far more like English. In fact you can even write:

    do_something() unless condition;

which is about as close to English as a programming language ever gets.

A Perl programmer once explained to me the moment when he realized that Perl
and he were made for each other was when he wrote some pseudocode which
described a possible solution to a problem and accidentally ran it through
the Perl interpreter. It ran correctly the first time.

As another example of how Perl makes it easier to write code that is easier to
read, consider opening a file. This is something that just about any kind of
program has to do at some point. This is a point in a program where error
checking is very important, and in many languages you will see large amounts
of code surrounding a file open statement. Code to open a file in C looks
like this:

    if ((f = fopen("file.txt", "r")) == NULL) {
      perror("file.txt");
      exit(0);
    }

whereas in Perl you can write it like this:

    open(FILE, 'file.txt') or die "Can't open file.txt: $!";

This opens a file and assigns it to the file handle FILE which you can later
use to read data from the file. It also checks for errors and, if anything goes
wrong, it kills the program with an error message explaining exactly what went
wrong. And, as a bonus, once more it almost reads like English.

Perl is not for everyone. Some people enjoy the verbosity of some other
lan guages or the rigid syntax of others. Those who do make an effort to
understand Perl typically become much more effective programmers.

Perl is not for every task. Many speed-critical routines are better written
in C or assembly language. In Perl, however, it is possible to split these
sections into separate modules so that the majority of the program can still
be written in Perl if desired.


### Getting Perl

One of the advantages of Perl is that it is free (as in both "free
speech" and "free beer"). The source code for Perl is available for
download from a number of web sites. The definitive site to get the
Perl source code (and, indeed, for all of your other Perl needs) is
www.perl.com, but the Perl source is mirrored at sites all over the
world. You can find the nearest one to you listed on the main site.
Once you have the source code, it comes with simple instructions on
how to build and install it. You’ll need a C compiler and a make
utility—[Gnu's gcc](https://gcc.gnu.org) should work for you.

Downloading source code and compiling your own tools is a common procedure
on UNIX systems. Many Windows developers, however, are more used to installing
prepackaged software. This is not a problem, as they can get a prebuilt binary
called [ActivePerl](https://www.activestate.com/products/perl/downloads/) from
[ActiveState](https://www.activestate.com). As with other
versions of Perl, this distribution is free.

### Why is Perl good for data munging?

Perl has a number of advantages that make it particularly useful as a data
munging language. Let’s take a look at a few of them.

* *Perl is interpreted* — Actually Perl isn’t really interpreted, but it
looks as though it is to the programmer. There is no separate compilation
phase that the programmer needs to run before executing a Perl program. This
makes the development of a Perl program very quick as it frees the programmer
from the edit-compile-test-debug cycle, which is typical of program
development in languages like C and C++.

* *Perl is compiled* — What actually happens is that a Perl program is
compiled automatically each time it is run. This gives a slight performance
hit when the program first starts up, but means that once the program is
running you don’t get any of the performance problems that you would from
a purely interpreted language.

* *Perl has powerful data recognition and transformation features* — A
lot of data munging consists of recognizing particular parts of the input
data and then transforming them. In Perl this is often achieved by using
regular expressions. We will look at regular expressions in some detail later
in the book, but at this point it suffices to point out that Perl’s regular
expression support is second to none.

* *Perl supports arbitrarily complex data structures* — When munging data,
you will usually want to build up internal data structures to store the data
in interim forms before writing it to the output file. Some programming
languages impose limits on the complexity of internal data structures. Since
the introduction of Perl 5, Perl has had no such constraints.

* *Perl encourages code reuse* — You will often be munging similar sorts of
data in similar ways. It makes sense to build a library of reusable code to
make writing new programs easier. Perl has a very powerful system for creating
modules of code that can be slotted into other scripts very easily. In fact,
there is a global repository of reusable Perl modules available across the
Internet at www.cpan.org. CPAN stands for the Comprehensive Perl Archive
Network. If someone else has previously solved your particular problem then you
will find a solution there. If you are the first person to address a particular
problem, once you’ve solved it, why not submit the solution to the CPAN. That
way everyone benefits.

* *Perl is fun* — I know this is a very subjective opinion, but the fact
remains that I have seen jaded C programmers become fired up with enthusiasm
for their jobs once they’ve been introduced to Perl. I’m not going to try to
explain it, I’m just going to suggest that you give it a try.

### Further information

The best place to get up-to-date information about Perl is the Perl home page
at www.perl.com.

Appendix B contains a brief overview of the Perl language, but if you want to
learn Perl you should look at one of the many Perl tutorial books. If you are
a non-programmer then *Elements of Programming with Perl* by Andrew Johnson
(Manning) would be a good choice. Programmers looking to learn a new language
should look at *Learning Perl (7th edition)* by Randal Schwartz, brian d foy, and Tom
Christiansen (O’Reilly) or *Perl: The Programmer’s Companion* by Nigel Chapman
(Wiley).

The definitive Perl reference book is *Programming Perl (4th edition)*
by Tom Christiansen, brian d foy, Larry  Wall, and Jon Orwant (O’Reilly).

Perl itself comes with a huge amount of documentation. Once you have installed
Perl, you can type perldoc perl at your command line to get a list of the
available documents.


## Summary

* Data munging is the process of taking data from one system (a data source)
and converting it so that it is suitable for use by a different system
(a data sink).

* Data munging consists of four stages—data recognition, parsing, filtering,
and transformation.

* Data can come from (and be written to) a large number of different types of
sources and sinks.

* Data itself can take a large number of forms, text or binary, unstructured or
structured, record oriented or hierarchical.

* Perl is a language which is very well suited for the whole range of data
munging jobs.

