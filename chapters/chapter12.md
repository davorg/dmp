Part IV - The big picture
=========================

This final section steps back from the specifics of any one data
format or technique to look at the bigger picture.

We close by reviewing why data munging matters, why Perl remains such
a good tool for it, and where to go next—both for further Perl
resources and for continuing to develop as a data munger long after
you've finished this book.

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

In [Chapter 1](ch004.xhtml), I said that data munging lived in the “interstices
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

In a classic article on perl.com, Mark-Jason Dominus talks about
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
article is at [Return of Program Repair Shop and Red Flags](https://www.perl.com/pub/2000/06/commify.html/).

### The usefulness of the Perl community

One of the best things about using Perl is the community that goes
with it. It seems to attract people who are only too happy to help
others—whether by submitting their code to the CPAN, answering a
technical question on a site like PerlMonks, or writing up what
they've learned as a blog post that gets picked up by Perl Weekly or
aggregated on Planet Perl for the rest of the community to find.

If you are going to use Perl, I would certainly encourage you to
become part of the Perl community. There are a number of ways to do
this:

*  Join your local Perl Mongers group. These are users’ groups. You can find the contact for your local group at www.pm.org. If there isn’t one for your area, why not form one?

*  Ask questions on [PerlMonks](https://www.perlmonks.org). It's been around since 1999 and still has a deep well of Perl expertise, even if the site itself shows its age these days.

*  Join [r/perl](https://www.reddit.com/r/perl) on Reddit. It's a small but active community for Perl news and discussion.

*  Subscribe to [Perl Weekly](https://perlweekly.com). It's a free weekly roundup of Perl news, blog posts, and CPAN releases—the easiest way to keep up with what the community is doing.

*  Try [The Weekly Challenge](https://theweeklychallenge.org). Two programming tasks are posted every Monday, one for beginners and one for experts—a great way to keep your Perl sharp and see how other people solve the same problem.

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
possible. This includes designing intermediate data structures
carefully and using the UNIX filter model to remove any assumptions
about input and output channels.

Know whether your data inputs or outputs are liable to change. If so,
can you design your program so that it makes no assumptions about
input and output formats? Can your program work out the format from
the actual input data? Or can the input and output formats be driven
from configuration files? Can you have some input into the design of
these formats? If so, can you make them flexible enough that one
output format can go to more than one sink? Or can more than one
source provide data in the same format? If not, can you munge the
formats in a preprocessing program to make them all the same?

You may also need to know about the operating system that data was
produced on or will be used on, as this may affect the format of the
data. Is it plain ASCII, Unicode (most likely, these days), or
something older like ISO-8859-X or Shift-JIS? Is binary data
big-endian or little-endian? What is the line end character sequence?

### Know your tools

Ensure that you are as comfortable as possible with Perl and its
features. The market for Perl-specific books has largely dried
up—like much of technical publishing, it's moved to the web, and big
publishers won't take a risk on a niche technology when a website
can cover the same ground for free and stay current. Two books are
still worth having on the shelf, because both remain in print and
reasonably current: [Learning
Perl](https://learning.oreilly.com/library/view/learning-perl-8th/9781492094951/)
and [Programming
Perl](https://learning.oreilly.com/library/view/programming-perl-4th/9781449321451/).
Older classics like [The Perl
Cookbook](https://learning.oreilly.com/library/view/perl-cookbook-2nd/0596003137/)
and [Object Oriented
Perl](https://www.manning.com/books/object-oriented-perl) are worth a
skim if you stumble across a copy—the underlying techniques still
hold up even though the exact syntax has moved on—but don't go out of
your way to track one down. For something
more current, look at [Perl School](https://perlschool.com/books):
it's been publishing Perl books since 2017, as ebooks and (more
recently) print-on-demand paperbacks, precisely because the
mainstream publishers had walked away from the topic—modern,
low-overhead production tools instead of a traditional publisher's
long lead times (this book is one of them). Read the documentation
that comes with Perl—it will be more up-to-date than any book. Know
what questions are answered in [perldoc
perlfaq](https://perldoc.perl.org/perlfaq) (and know their answers).
Subscribe to [Perl Weekly](https://perlweekly.com) and follow [Planet
Perl](https://perl.theplanetarium.org/) for a steady stream of what
the community is writing and thinking about.

Understand common Perl methods such as complex sorting techniques.
Learn how to benchmark your programs. Find the best performing
solution to the problem (but know when your solution is fast
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

*  [The Perl Home Page](https://www.perl.org)—The official home of Perl: news, downloads, and documentation.

*  [perl.com](https://www.perl.com)—Not the official site (that's perl.org), but still worth checking for articles and interviews.

*  [perldoc perl](https://perldoc.perl.org) *(and others)*—The best Perl documentation installed right on your computer.

*  [Learning Perl](https://learning.oreilly.com/library/view/learning-perl-8th/9781492094951/) (O’Reilly), Randal L. Schwartz, brian d foy, and Tom Phoenix—The classic beginner's introduction. Still in print, still current (8th edition, 2021).

*  [Programming Perl](https://learning.oreilly.com/library/view/programming-perl-4th/9781449321451/) (O’Reilly), Larry Wall, Tom Christiansen, and Jon Orwant—The essential Perl reference. Make sure you get the 4th edition.

*  [Perl School](https://perlschool.com/books)—Perl books, published as ebooks and print-on-demand paperbacks since 2017, using modern, low-overhead production tools instead of a traditional publisher's long lead times. This book is one of them.

*  [Perl Weekly](https://perlweekly.com)—A free weekly newsletter rounding up Perl news, blog posts, and CPAN releases.

*  [Planet Perl](https://perl.theplanetarium.org/)—An aggregator collecting Perl blog posts from across the community, and the best place to read what people are actually writing about Perl. (The classic planet.perl.org address now just redirects to perl.org—this is its current successor.)

*  [The Weekly Challenge](https://theweeklychallenge.org)—Two Perl programming tasks every week, running continuously since 2019.

*  [The Perl and Raku Conference](https://tprc.us/) (TPRC)—The community's flagship annual conference, held in a different city each year.

*  [The Perl & Raku Foundation](https://www.perlfoundation.org/)—A non-profit that funds Perl development, holds Perl's trademarks, and organizes and sponsors community events.

*  [r/perl](https://www.reddit.com/r/perl)—A small, active Reddit community for Perl news and discussion.

*  [Stack Overflow's `perl` tag](https://stackoverflow.com/questions/tagged/perl)—New questions have slowed to a trickle there in recent years, but the huge archive of existing Perl Q&A is still a goldmine when you're searching for an answer.

*  [The Perl Mongers](http://www.pm.org)—Friendly Perl people in your town. www.pm.org.

*  [Perl Monks](https://www.perlmonks.org)—A web site where Perl programmers help each other with Perl problems. http://www.perlmonks.org.
