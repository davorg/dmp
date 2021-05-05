Part II: Data munging
=====================

In which our heroes first come into contact with the data munging
beast. Three times they battle it, and each time the beast takes on a
different form.

At first the beast appears without structure and our heroes fight
valiantly to impose structure upon it. They learn new techniques for
finding hidden structure and emerge triumphant.

The second time the beast appears structured into records. Our heroes
find many ways to split the records apart and recombine them in other
useful ways.

The third time the beast appears in even more strongly structured
forms. Once again our heroes discover enough new techniques to see
through all of their enemies’ disguises.

Our heroes end this section of the tale believing that they can
handle the beast in all of its guises, but disappointment is soon to
follow.


Chapter 5: Unstructured Data
=============================

What this chapter covers:

*  Reading an ASCII file

*  Producing text statistics

*  Performing format conversions

*  Reformatting numbers


The simplest kind of data that can require munging is unstructured
data. This is data that has no internal structure imposed on it in
any way. In some ways this is the most difficult data to deal with as
there is often very little that you can do with it.

A good example of unstructured data is a plain ASCII file that
contains text. In this chapter we will look at some of the things
that we can do with a file like this.

ASCII text files
----------------


An ASCII text file contains data that is readable by a person. It can
be created in a text editor like vi or emacs in UNIX, Notepad in
Windows, or edit in DOS. You should note that the files created by
most word processors are not ASCII text, but some proprietary text
format. !!! Footnote  1 Most word processors do have a facility to save the document in ASCII text format; however, this will destroy most of the formatting of the document.
!!! It is also possible that the file could be created by some
other computer system.

An ASCII text file, like all data files, is nothing but a series of
bytes of binary data. It is only the software that you use to view
the file (an editor perhaps) that interprets the different bytes of
data as ASCII characters.

### Reading the file


One of the simplest things that we can do with an ASCII file is to
read it into a data structure for later manipulation. The most
suitable format for the data structure depends, of course, on the
exact nature of the data in the file and what you are planning to
do with it, but for readable text an array of lines will probably be
the most appropriate structure. If you are interested in the
individual words in each line then it will probably make sense to
split each line into an array of words. Notice that because order is
important when reading text we use Perl arrays (which are also
ordered) to store the data, rather than hashes (which are unordered).

#### Example: Reading text into an array of arrays

Let’s write an input routine that will read an unstructured text file
into an array of arrays. As always we will assume that the file is
coming to us via STDIN.

	1: sub read_text {
	2:
	3:   my @file;
	4:
	5:   push @file, [split] while <STDIN>;
	6:
	7:   return \@file;
	8: }

Let’s look at this line by line.

Line 3 defines a variable that will contain the array of lines. Each
element of this array will be a reference to another array. Each
element of these second-level arrays will contain one of the words
from the line.

Line 5 does most of the work. It might be easier to follow if you
read it in reverse. It is actually a contraction of code that, when
expanded, looks something like this:

	while (<STDIN>) {
	  my @line = split(/\s+/, $_);
	  push @file, [@line];
	}

which may be a little easier to follow. For each line in the file, we
split the line wherever we see one or more white space characters.
We then create an anonymous array which is a copy of the array
returned by split and push the reference returned by the anonymous
array constructor onto an `@file`.

Also implicit in this line is our definition of a word. In this case
we are using Perl’s built-in `\s` character class to define our word
separators as white space characters (recall that split uses `\s+`
as the delimiter by default). Your application may require something
a little more complicated.

Line 7 returns a reference to the array.

Our new function can be called like this:

	my $file = read_text;

and we can then access any line of the file using

	my $line = $file->[$x];

where `$x` contains the number of the line that we are interested in.
After this call, `$line` will contain a reference to the line array.
We can, therefore, access any given word using

	my $word = $line->[$y];

or, from the original `$file` reference:

	my $word = $file->[$x][$y];

Of course, all of this is only a very good idea if your text file is
of a reasonable size, as attempting to store the entire text of *War
and Peace* in memory may cause your computer to start swapping memory
to disk, which will slow down your program. !!! Footnote 2 Then
again, if you have enough memory that you can store the entire text
of *War and Peace* in it without swapping to disk, that would be the
most efficient way to process it. !!!


#### Finer control of input

If you are, however, planning to store all of the text in memory then
there are a couple of tricks that might be of use to you. If you want
to read the file into an array of lines without splitting the lines
into individual words, then you can do it in one line like this:

	my @file = <FILE>;

If, on the other hand, you want the whole text to be stored in one
scalar variable then you should look at the `$/` variable. This
variable is the input record separator and its default value is a
newline character. This means that, by default, data read from a `<>`
operator will be read until a newline is encountered. Setting this
variable to undef will read the whole input stream in one go.  !!!
Footnote 3 Note that `$/` (like most Perl internal variables) is, by
default, global, so altering it in one place will affect your whole
program. For that reason, it is usually a good idea to use local and
enclosing braces to ensure that any changes have a strictly limited
scope.!!! You can, therefore, read in a whole file by doing this

	local $/ = undef;
	my $file = <FILE>;

You can set `$/` to any value that your program will find useful.
Another value that is often used is an empty string. This puts Perl
into paragraph mode where a blank line is used as the input
delimiter.

If your file is too large to fit efficiently into memory then you are
going to have to process a row at a time (or a record at a time if
you have changed `$/`). We will look at line-based and record-based
data in the [next chapter](ch010.xhtml), but for the rest of this chapter we will
assume that we can get the whole file in memory at one time.

### Text transformations

Having read the file into our data structures, the simplest thing to
do is to transform part of the data using the simple regular
expression techniques that we discussed in the [last chapter](ch007.xhtml). In this
case the lines or individual words of the data are largely irrelevant
to us, and our lives become much easier if we read the whole file
into a scalar variable.

#### Example: simple text replacement

For example, if we have a text file where we want to convert all
instances of “Windows” to “Linux”, we can write a short script like
this:

	my $file;
	{
	local $/ = undef;
	$file = <STDIN>;
	}
	$file =~ s/Windows/Linux/g;
	print $file;

Notice how the section that reads the data has been wrapped in a bare
block in order to provide a limited scope for the local copy of the
`$/` variable. Also, we have used the g modifier on the substitution
command in order to change all occurrences of Windows.

All of the power of regular expression substitutions is available to
us. It would be simple to rewrite our translation program from the
[previous chapter](ch007.xhtml) to translate the whole input file in one operation.

### Text statistics

One of the useful things that we can do is to produce statistics on
the text file. It is simple to produce information on the number of
lines or words in a file. It is only a little harder to find the
longest word or to produce a table that counts the occurrences of
each word. In the following examples we will assume that a file is
read in using the `read_text` function that we defined earlier in the
chapter. This function returns a reference to an array of arrays. We
will produce a script that counts the lines and words in a file and
then reports on the lengths of words and the most-used words in the
text.

#### Example: producing text statistics

	  1: # Variables to keep track of where we are in the file
 	  2: my ($line, $word);
	  3:
	  4: # Variables to store stats
	  5: my ($num_lines, $num_words);
	  6: my (%words, %lengths);
	  7:
	  8: my $text = read_text();
	  9:
	 10: $num_lines = scalar @{$text};
	 11:
	 12: foreach $line (@{$text}) {
	 13:   $num_words += scalar @{$line};
	 14:
	 15:   foreach $word (@{$line}) {
	 16:     $words{$word}++;
	 17:     $lengths{length $word}++;
	 18:   }
	 19: }
	 20:
	 21: my @sorted_words = sort { $words{$b} <=> $words{$a} } keys %words;
	 22: my @sorted_lengths = sort { $lengths{$b} <=> $lengths{$a} } keys %lengths;
	 23:
	 24: print "Your file contains $num_lines lines ";
	 25: print "and $num_words words\n\n";
	 26:
	 27: print "The 5 most popular words were:\n";
	 28: print map { "$_ ($words{$_} times)\n" } @sorted_words[0..4];
	 29:
	 30: print "\nThe 5 most popular word lengths were:\n";
	 31: print map { "$_ ($lengths{$_} words)\n" } @sorted_lengths[0..4];

Line 2 declares two variables that we will use to keep track of where
we are in the file.

Lines 5 and 6 declare four variables that we will use to produce the
statistics. $num_lines and $num_words are the numbers of lines and
words in the file. %words is a hash that will keep a count of the
number of times each %word has occurred in the file. Its key will be the word and its value
%will be the number of times the word has been seen. %lengths is a hash that
keeps count of the frequency of word lengths in a similar fashion.

Line 8 calls our read_text function to get the contents of the file.

Line 10 calculates the number of lines in the file. This is simply the
number of elements in the $text array.

Line 12 starts to loop around each line in the array.

Line 13 increases the $num_words variable with the number of
elements in the $line array. This is equal to the number of words in
the line.

Line 15 starts to loop around the words on the line.

Lines 16 and 17 increment the relevant entries in the two hashes.

Lines 21 and 22 create two arrays which contain the keys of the %words
and %lengths hashes, sorted in the order of decreasing hash values.

Lines 24 and 25 print out the total number of words and lines in the
file.

Lines 27 and 28 print out the five most popular words in the file by
taking the first five elements in the @sorted_words array and
printing the value associated with that key in the %words hash. Lines
30 and 31 do the same thing for the @sorted_lengths array.

#### Example: calculating average word length

As a final example of producing text file statistics, let’s calculate
the average word length in the files. Once again we will use the
existing read_text function to read in our text.

	my ($total_length, $num_words);
	my $text = read_text();
	my ($word, $line);
	foreach $line (@{$text}) {
	$num_words += scalar @{$line};
	foreach $word (@{$line}) {
	$total_length += length $word;
	}
	}
	printf "The average word length is %.2f\n", $total_length /
	$num_words;

Data conversions
----------------

One of the most useful things that you might want to do to
unstructured data is to perform simple data format conversions on it.
In this section we’ll take a look at three typical types of
conversions that you might need to do.

### Converting the character set

Most textual data that you will come across will be in ASCII, but
there may well be occasions when you have to deal with other
character sets. If you are exchanging data with IBM mainframe systems
then you will often have to convert data to and from EBCDIC. You may
also come across multibyte characters if you are dealing with data
from a country where these characters are commonplace (like China or
Japan).

#### Unicode

For multibyte characters, Perl version 5.6 includes some support for
Unicode via the new utf8 module. This was introduced in order to make
it easier to work with XML using Perl (XML uses Unicode in UTF-8
format to define all of its character data). If you have an older
version of Perl you may find the Unicode::Map8 and Unicode::String
modules to be interesting.

#### Converting between ASCII and EBCDIC

For converting between ASCII and EBCDIC you can use the
Convert::EBCDIC module from the CPAN. This module can be used either
as an object or as a traditional module. As a traditional module, it
exports two functions called ascii2ebcdic and ebcdic2ascii. Note that
these functions need to be explicitly imported into your namespace. As
an object, it has two methods called toascii and toebcdic. The
following example uses the traditional method to convert the ASCII
data arriving on STDIN into EBCDIC.

	use strict;
	use Convert::EBCDIC qw/ascii2ebcdic/;
	my $data;


	{
	local $/ = undef;
	$data = <STDIN>;
	}
	print ascii2ebcdic($data);
	The second example uses the object interface to convert EBCDIC data to
	ASCII.
	use strict;
	use Convert::EBCDIC;
	my $data;
	my $conv = Convert::EBCDIC->new;
	my $data;
	{
	local $/ = undef;
	$data = <STDIN>;
	}
	print $conv->toascii($data);

The Convert::EBCDIC constructor takes one optional parameter which is
a 256 character string which defines a translation table.

### Converting line endings

As I mentioned above, an ASCII text file is no more than a stream of
binary data. It is only the software that we use to process it that
interprets the data in such a way that it produces lines of text. One
important character (or sequence of characters) in a text file is the
character which separates different lines of text. When, for exam-
ple, a text editor reaches this character in a file, it will know
that the following characters must be displayed starting at the
first column of the following line of the user’s display.

#### Different line end characters

Over the years, two characters in particular have come to be the most
commonly used line end characters. They are the characters with the
ASCII codes 10 (line feed) and 13 (carriage return). The line feed is
used by UNIX (and Linux) systems. Apple Macintoshes use the carriage
return. DOS and Windows use a combination of both characters, the
carriage return followed by the line feed.

This difference in line endings causes no problems when data files
are used on the same system on which they were created, but when you
start to transfer data files between different systems it can lead to
some confusion. You may have edited a file that was created under
Windows in a UNIX text editor. If so you will have seen an extra ^M
character at the end of each line of text.!!! Footnote 4 This is becoming less common as many editors will now display the lines without the ^M, and indicate the newline style in the status line. !!! This is the printable
equivalent of the carriage return character that Windows inserts
before each line feed. Similarly, a UNIX text file opened in Windows
Notepad will have no carriage returns before the line feed and,
therefore, Notepad will not recognize the end of line character
sequence. All the lines will subsequently be run together, separated
only by a black rectangle, which is Windows’ way of representing the
unprintable line feed character.

There are ways to avoid this problem. Transferring files between
systems using FTP in ASCII mode, for example, will automatically
convert the line endings into the appropriate form. It is almost
guaranteed, however, that at some point you will find yourself
dealing with a data file that has incorrect line endings for your
system. Perl is, of course, the perfect language for correcting this
problem.

#### Example: a simple line end conversion filter

The following program can be used as a filter to clean up problem
files. It takes two parameters, which are the line endings on the
source and target systems. These are the strings CR, LF, or CRLF.

In the program, instead of using \n and \r we use the ASCII control
character sequences \cM and \cJ (Ctrl-M and Ctrl-J). This is
because Perl is cleverer than we might like it to be in this case.
Whenever Perl sees a \n sequence in a program it actually converts
it to the correct end-of-line character sequence for the current
system. This is very useful most of the time (it means, for example,
that you don’t need to use print "some text\r\n"; to output text
when using Perl on a Windows system). But in this situation it masks
the very problem that we’re trying to solve—so we have to go to a
lower level representation of the characters.

	#!/usr/local/bin/perl -w
	use strict;
	(@ARGV == 2) or die "Error: source and target formats not given.";
	my ($src, $tgt) = @ARGV;
	my %conv = (CR =>
	"\cM",
	LF =>
	"\cJ",
	CRLF => "\cM\cJ");
	$src = $conv{$src};
	$tgt = $conv{$tgt};
	$/ = $src;
	while (<STDIN>) {
	s/$src/$tgt/go;
	print;
	}

Notice that we use the o modifier on the substitution as we know that
the source will not change during the execution of the while loop.

### Converting number formats

Sometimes the unstructured data that you receive will contain
numerical data and the only changes that you will want to make are to
reformat the numbers into a standardized format. This breaks down
into two processes. First you have to recognize the numbers you are
interested in, then you need to reformat them.

#### Recognizing numbers

How do you recognize a number? The answer depends on what sort of
numbers you are dealing with. Are they integers or floating points?
Can they be negative? Do you accept exponential notation (such as 1E6
for 1 × 106)? When you answer these questions, you can build a regular
expression that matches the particular type of number that you need to
process.

To match natural numbers (i.e., positive integers) you can use a
simple regular expression such as:

	/\d+/

To match integers (with optional +/- signs) use

	/[-+]?\d+/

To match a floating point number use

 	/[-+]?(\d+(\.\d*)?|\.\d+)/

To match a number that can optionally be in exponential notation, use

 	/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/

As these become rather complex, it might be a suitable time to
consider using Perl’s precompiled regular expression feature and
creating your number-matching regular expressions in advance. You can
do something like this:

	my $num_re =
	qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/;
	my @nums;
	while ($data =~ /$num_re/g) {
	push @nums, $1;
	}

to print out a list of all of the numbers in $data.

If you have a function, reformat, that will change the numbers into
your preferred format then you can use code like this:

	$data =~ s/$num_re/reformat($1)/ge;

which makes use, once more, of the e modifier to execute the
replacement string before using it.

#### Reformatting numbers with sprintf

The simplest way to reformat a number is to pass it through sprintf.
This will enable you to do things like fix the number of decimal
places, pad the start of the number with spaces or zeroes, and right
or left align the number within its field. Here is an example of the
sort of things that you can do:

	my $number = 123.456789;
	my @fmts = ('0.2f', '.2f', '10.4f', '-10.4f');
	foreach (@fmts) {
	my $fmt = sprintf "%$_", $number;
	print "$_: [$fmt]\n";
	}

which gives the following output:

	**0.2f: [123.46]**
	**.2f: [123.46]**
	**10.4f: [**
	**123.4568]**
	**-10.4f: [123.4568**
	**]**

(The brackets are there to show the exact start and end of each output
field.)

#### Reformatting numbers with CPAN modules

There are, however, a couple of modules available on the CPAN which
allow you to do far more sophisticated formatting of numbers. They are
Convert::SciEng and Number::Format.

#### Convert::SciEng

Convert::SciEng is a module for converting numbers to and from a
format in which they have a postfix letter indicating the magnitude
of the number. This conversion is called *fixing* and *unfixing*
the number. The module recognizes two different schemes of fixes, the
SI scheme and the SPICE scheme. The module interface is via an
object interface. A new object is created by calling the class new
method and passing it a string indicating which fix scheme you want
to use (SI or SPICE).

	my $conv = Convert::SciEng->new('SI');

You can then start fixing and unfixing numbers. The following:

	 print $conv->unfix('2.34u');

will print the value 2.34e-06. The “u” is taken to mean the SI symbol
for microunits.

You can also pass an array to unfix, as in

	print map { "$_\n" } $conv->unfix(qw/1P 1T 1G 1M 1K 1 1m 1u 1p 1f 1a/);

 which will produce the output

	 1e+015
	 1000000000000
	 1000000000
	 1000000
	 1000
	 1
	 0.001
	 1e-006
	 1e-012
	 1e-015
	 1e-018

(and also demonstrates the complete range of postfixes understood by
the SI scheme).

You can also adjust the format in which the results are returned in
by using the format method and passing it a new format string. The
format string is simply a string that will be passed to sprintf
whenever a value is required. The default format is %5.5g.

There is, of course, also a fix method that takes a number and
returns a value with the correct postfix letter appended:

	print $conv->fix(100_000)

prints “100K” and

	print $conv->fix(1_000_000)

prints “1M”.

#### Number::Format

The Number::Format module is a more general-purpose module for
formatting numbers in interesting ways. Like Convert::SciEng, it is
accessed through an object-oriented interface. Calling the new method
creates a new formatter object. This method takes as its argument a
hash which contains various formatting options. These options are
detailed in appendix A along with the other object methods contained
within Number::Format.

Here are some examples of using this module:

	my $fmt = Number::Format->new; # use all defaults
	my $number = 1234567.890;

	print $fmt->round($number), "\n";
	print $fmt->format_number($number), "\n";
	print $fmt->format_negative($number), "\n";
	print $fmt->format_picture($number, '###########'), "\n";
	print $fmt->format_price($number), "\n";
	print $fmt->format_bytes($number), "\n";
	print $fmt->unformat_number('1,000,000.00'), "\n";

This results in:

	1234567.89
	1,234,567.89
	-1234567.89
	1234568
	USD 1,234,567.89
	1.18M
	1000000

Changing the formatting options slightly:

	my $fmt = Number::Format->new(INTL_CURRENCY_SYMBOL => 'GBP', DECIMAL_DIGITS => 1);
	my $number = 1234567.890;
	print $fmt->round($number), "\n";
	print $fmt->format_number($number), "\n";
	print $fmt->format_negative($number), "\n";
	print $fmt->format_picture($number, '###########'),
	"\n";
	print $fmt->format_bytes($number), "\n";
	print $fmt->unformat_number('1,000,000.00'), "\n";

results in:

	1234567.9
	1,234,567.9
	-1234567.89
	1234568
	GBP 1,234,567.89
	1.18M
	1000000

If we were formatting numbers for a German system, we might try
something like this:

	my $de = Number::Format->new(INT_CURR_SYMBOL => 'DEM ',
	THOUSANDS_SEP => '.',
	DECIMAL_POINT => ',');
	my $number = 1234567.890;
	print $de->format_number($number), "\n";
	print $de->format_negative($number), "\n";
	print $de->format_price($number), "\n";

which would result in:

	 1.234.567,89
	 -1234567.89
	 DEM 1.234.567,89

And finally, if we were accountants, we might want to do something like
this:

	my $fmt = Number::Format->new(NEG_FORMAT=> '(x)');
	my $debt = -12345678.90;
	print $fmt->format_negative($debt);

which would give us:

	(12345678.90)

It is, of course, possible to combine Number::Format with some of the
other techniques that we were using earlier. If we had a text document
that contained numbers in different formats and we wanted to ensure
that they were all in our standard format we could do it like this:

	use Number::Format;
	my $data;
	{
	local $/ = undef;
	$data = <STDIN>;
	}
	my $fmt = Number::Format->new;
	my $num_re =
	qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/;
	$data =~ s/$num_re/$fmt->format_number($1)/ge;
	print $data;

Further information
-------------------

For more information about input control variables such as $/, see
the perldoc perlvar manual pages.

For more information about the Unicode support in Perl, see the
perldoc perlunicode and perldoc utf8 manual pages.

For more information about sprintf, see the perldoc -f sprintf manual
page. Both Convert::SciEng and Number::Format can be found on the
CPAN.

Once you have installed them, their documentation will be available
using the perldoc command.

Summary
-------

*  Most unstructured data is found in ASCII text files.

*  Perl can be used to extract statistics from text files very easily.

*  Many useful data format conversions can be carried out either using the standard Perl distribution or with the addition of modules from the CPAN.
