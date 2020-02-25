Chapter 12: Looking Back and Ahead
==================================

What this chapter covers:

*  Why munge data?

*  Just how useful is Perl?

*  Where can I find Perl support?

*  Where can I find more information?

The received wisdom for giving a presentation is that you should
“tell them what you’re going to tell them, tell them, and then tell
them what you’ve told them.” A book is no different in principle to a
presentation, so in this chapter we’ll review what we’ve covered and
discuss where you can go for more information.

The usefulness of things
------------------------

A brief reminder of why you munge data and, more importantly, why you
should munge it using Perl.

### The usefulness of data munging

In chapter 1 I said that data munging lived in the “interstices
between computer systems.” I hope that you can now see just how
all-pervasive it is. There are very few computing tasks that don’t
involve munging data to some degree. From the run-once command line
script which loads data files into a new database, to the
many-thousand lines of code which run bank’s accounting systems, they
are all munging data in one way or another.

### The usefulness of Perl

The next aim of the book was to demonstrate how well Perl fits into
the data munging problem space. By allowing programmers to define a
problem in a way that is closer to the way that their thought
processes work and further from the way that computer CPUs work, many
programmers find that using Perl makes them far more productive.

In a recent article on www.perl.com, Mark-Jason Dominus talks about
the difference between “natural” code and “synthetic” code. Natural
code is the code which is fundamentally tied in with solving the
problem at hand. Synthetic code is code which is merely a side effect
of the programming constructs that you use to solve the problem. A
good example of synthetic code is a loop counter. In many programming
languages, if you wanted to iterate across an array you would need to
write code similar to this:

	 for ($i = 0; $i <= $#arr; $i++) {
	   some_function($arr[$i]);
	 }

You can, of course, write code like this in Perl (as the sample
demonstrates), but a far more Perlish way to write it is like this:

	 foreach (@arr) {
	   some_function($_);
	 }

Because the second version removes all of the synthetic code required
to iterate across an array, it is far easier for a programmer to
follow exactly what is happening.

Synthetic code only gets in the way of a programmer’s understanding of
a program so the goal must always be to eliminate as much of it as
possible. Because Perl is particularly good at allowing programmers to
model the problem exactly, it follows that you end up with a far
smaller amount of synthetic code than in many other languages.

If you’re interested in reading more (and you *should* be), Dominus’
article is at http://www.perl.com/pub/2000/06/commify.html.

### The usefulness of the Perl community

One of the best things about using Perl is the community that goes with it. It seems to attract people who are only too happy to help others—whether by sub- mitting their code to the CPAN, answering a technical question in a newsgroup such as comp.lang.perl.misc, or on a website like Perl Monks, or even writing arti- cles for *The Perl Journal*.

If you are going to use Perl, I would certainly encourage you to become part of the Perl community. There are a number of ways to do this:

*  Join your local Perl Mongers group. These are users’ groups. You can find the contact for your local group at www.pm.org. If there isn’t one for your area, why not form one?

*  Visit comp.lang.perl.misc regularly. This is the main Perl newsgroup. As long as you follow the rules of Netiquette, you will be very welcome there.

*  Read *The Perl Journal*. This is the only printed magazine dedicated to Perl. You can subscribe at www.tpj.com.

*  Submit your code to the CPAN. If you have written code which could be of use to others, why not put it in a place where everyone can find it? Details on becoming a CPAN author can be found at www.cpan.org.

Things to know
--------------

A brief list of things that you should know to make your data munging
work as easy as possible.

### Know your data

When munging data, the more that you know about your source and your
sink, the better you will be able to design your program and, perhaps
more importantly, your intermediate data structures. You need to know
as much as possible about not only the format of the data, but also
what it will be used for, as this will help you to build flexibility
into your program. Always design your program to be as flexible as
possi- ble. This includes designing intermediate data structures
carefully and using the UNIX filter model to remove any assumptions
about input and output channels.

Know whether your data inputs or outputs are liable to change. If so,
can you design your program so that it makes no assumptions about
input and output for- mats? Can your program work out the format from
the actual input data? Or can the input and output formats be driven
from configuration files? Can you have some input into the design of
these formats? If so, can you make them flexible enough that one
output format can go to more than one sink? Or can more than one
source provide data in the same format? If not, can you munge the
formats in a preprocessing program to make them all the same?

You may also need to know about the operating system that data was
produced on or will be used on, as this may affect the format of the
data. Is it in ASCII, EBCDIC or Unicode? Is binary data big-endian or
little-endian? What is the line end character sequence?

### Know your tools

Ensure that you are as comfortable as possible with Perl and its
features. Buy and read Perl books. All Perl programmers should have
read *Programming Perl, The Perl Cookbook*, *Mastering Regular
Expressions*, and *Object Oriented Perl.* Read the documentation that
comes with Perl—it will be more up-to-date than any book. Know what
questions are answered in perldoc perlfaq (and know their answers).
Subscribe to *The Perl Journal* (and consider buying a complete set of
back issues).

Understand common Perl methods such as complex sorting techniques.
Learn how to benchmark your programs. Find the best performing
solution to the prob- lem (but know when your solution is fast
enough).

Visit the CPAN often enough to have an overview of what is there. If a
module will solve your problem then install it and save yourself
writing more code than is necessary. If a module will almost solve
your problem then consider contacting the author and suggest
improvements. Even better, supply patches.

### Know where to go for more information

Here is a list of sources for information about Perl. Most of them
have been mentioned at some point in the book, but I thought it would
be useful to gather them together in one place.

*  *The Perl Home Page*—Definitive source for all things Perl: www.perl.com

*  *comp.lang.perl.misc*—The most active Perl newsgroup.

*  **perldoc perl** *(and others)*—The best Perl documentation installed right on your computer.

*  *Programming Perl* (O’Reilly), Larry Wall, Tom Christiansen, and Jon Orwant—The essential Perl book. Make sure you get the 3rd edition.

*  *The Perl Cookbook* (O’Reilly), Tom Christiansen and Nathan Torkington— The essential Perl book (volume 2).

*  *Mastering Regular Expressions* (O’Reilly), Jeffrey Friedl—Everything you ever wanted to know about regexes.

*  *Object Oriented Perl* (Manning), Damian Conway—Everything you ever wanted to know about programming with objects in Perl.

*  *The Perl Journal*—The only Perl magazine.

*  *The Perl Mongers*—Friendly Perl people in your town. www.pm.org.

*  *Perl Monks*—A web site where Perl programmers help each other with Perl problems. http://www.perlmonks.org.
