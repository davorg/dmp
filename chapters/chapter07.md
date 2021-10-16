Chapter 7: Fixed-width and binary data
======================================

What this chapter covers:

*  Reading fixed-width data

*  Using regular expressions with fixed-width data

*  Writing fixed-width data

*  Graphics file formats

*  Reading and writing MP3 files


In this chapter we will complete our survey of simple data formats by
examining fixed-width and binary data. Many of the methods we have
discussed in previous chapters will still prove to be useful, but we
will also look at some new tricks.

Fixed-width data
----------------

Fixed-width data is becoming less common, but it is still possible
that you will come across it, particularly if you are exchanging data
with an older computer system that runs on a mainframe or is written
in COBOL.

### Reading fixed-width data

In a fixed-width data record, there is nothing to distinguish one data
item from the next one. Each data item is simply written immediately
after the preceding one, after padding it to a defined width. This
padding can either be with zeroes or with spaces and can be before or
after the data. !!!FOOTNOTE  1 Although it is most common to find numerical data prepadded with zeroes and text data postpadded with spaces.
!!! In order to interpret the data, we need more
information about the way it has been written. This is normally sent
separately from the data itself but, as we shall see later, it is also
possible to encode this data within the files.

Here is an example of two fixed-width data records:

	 00374Bloggs & Co        19991105100103+00015000
	 00375Smith Brothers     19991106001234-00004999

As you can see, it’s tricky to understand exactly what is going on
here. It looks as though there is an ascending sequence number at the
start and perhaps a customer name. Some of the data in the middle
looks like it might be a date—but until we get a full definition of
the data we can’t be sure even how many data fields there are.

Here is the definition of the data:

*  *Columns 1 to 5*—Transaction number (numeric)

*  *Columns 6 to 25*—Customer name (text)

*  *Columns 26 to 33*—Date of transaction (YYYYMMDD)

*  *Columns 34 to 39*—Customer’s transaction number (numeric)

*  *Column 40*—Transaction direction (+/-)

*  *Columns 41 to 48*—Amount of transaction (numeric with two implied decimal places)


Now we can start to make some sense of the data. We can see that on
November 5, 1999, we received a check (number 100103) for $150.00
from Bloggs & Co. and on November 6, 1999, we paid $49.99 to Smith
Brothers in response to their invoice number 1234.

#### Example: extracting fixed-width data fields with substr\

So how do we go about extracting that information from the data?
Here’s a first attempt using the substr function to do the work:

	my @cols = qw(5 25 33 39 40 48);
	while (<STDIN>) {
	  my @rec;
	  my $prev = 0;
	  foreach my $col (@cols) {
	    push @rec, substr($_, $prev, $col - $prev);
	    $prev = $col;
	  }
	  print join('¦', @rec);
	  print "\n";
	}

While this code works, it’s not particularly easy to understand. We
use an array of column positions to tell us where each column ends.
Notice that we’ve actually used the positions where the columns begin
rather than end. This is because the column definitions that we were
given start from column one, whereas Perl arrays start from zero—all
in all, not the most maintainable piece of code.

#### Example: extracting fixed-width data with regular expressions\

Perhaps we’d do better if we used regular expressions:

	 my @widths = qw(5 20 8 6 1 8);
	 my $regex;
	 $regex .= "(.{$_})" foreach @widths;
	 while (<STDIN>) {
	   my @rec = /$regex/;
	   print join('¦', @rec);
	   print "\n";
	 }

In this case we’ve switched from using column start (or end)
positions to using column widths. It’s not very difficult to build
this list given our previous list. We then use the list of widths to
construct a regular expression which we can match against each row of
our data file in turn. The regular expression that we build looks
like this:


	(.{5})(.{20})(.{8})(.{6})(.{1})(.{8})

which is really a very simple regular expression. For each column in
the data record, there is an element of the form (.{x}), where x is
the width of the column. This element will match any character x
times and the parentheses will save the result of the match. Matching
this regular expression against a data record and assigning the
result to an array will give us a list containing all of the $1, $2,
… $n variables in order. This isn’t a very interesting use of regular
expressions. There must be a better way.

#### Example: extracting fixed-width data with unpack

In this case the best way is to use Perl’s unpack function. unpack
takes a scalar expression and breaks it into a list of values
according to a template that it is given. The template consists of a
sequence of characters which define the type and size of the
individual fields. A simple way to break apart our current data would
be like this:

	my $template = 'a5a20a8a6aa8';
	while (<STDIN>) {
	  my @rec = unpack($template, $_);
	  print join('¦', @rec);
	  print "\n";
	}

which returns exactly the same set of data that we have seen in all
of the examples above. In this case our template consists of the
letter a for each field followed by the length of the field (the
length is optional on single-character fields like our +/- field).
The a designates each field as an ASCII string, but the template can
contain many other options. For reference, here is one of the data
lines that was produced by the previous example:

	00374¦Bloggs & Co           ¦19991105¦100103¦+¦00015000

Notice that the numbers are still prepadded with zeroes and the string
is still postpadded with spaces. Now see what happens if we replace
each a in the template with an A.

	00374¦Bloggs & Co¦19991105¦100103¦+¦00015000

The spaces at the end of the string are removed. Depending on your
application, this may or may not be what you want. Perl gives you the
flexibility to choose the most appropriate route. There are a number
of other options that can be used in the unpack template and we’ll
see some more of them when we look at binary data in more detail. For
ASCII data, only a and A are useful.

#### Multiple record types

One slight variation of the fixed-width data record has different sets
of data fields for different types of data within the same file.
Consider a system that maintains a product list and, at the end of
each day, produces a file that lists all new products added and old
products deleted during the day. For a new product, you will need a
lot of data (perhaps product code, description, price, stock count and
supplier identifier). For the deleted product you only need the
product code (but you might also list the product description to make
the report easier to follow). Each record will have some kind of
identifier and the start of the line denoting which kind of record it
is. In our example they will be the strings ADD and DEL. Here are some
sample data:

    ADD0101Super Widget   00999901000SUPP01
    ADD0102Ultra Widget   01499900500SUPP01
    DEL0050Basic Widget
    DEL0051Cheap Widget

On the day covered by this data, we have added two new widgets to our
product catalogue. The Super Widget (product code 0101) costs $99.99
and we have 1000 in stock. The Ultra Widget (product code 0102) costs
$149.99 and we have 500 in stock. We purchase both new widgets from
the same supplier. At the same time we have discontinued two older
products, the Basic Widget (Product Code 0050) and the Cheap Widget
(Product Code 0051).

#### Example: reading multiple fixed-width record types

A program to read a file such as the previous example might look like
this:

	my %templates = (ADD => 'a4A14a6a5a6', DEL => 'a4A14');

	while (<STDIN>) {
	  my ($type, $data) = unpack('a3a*', $_);
	  my @rec = unpack($templates{$type}, $data);
	  print "$type - ", join('¦', @rec);
	  print "\n";
	}

In this case we are storing the two possible templates in a hash and
unpacking the data in two stages. In the first stage we separate the
record type from the main part of the data. We then use the record
type to choose the appropriate template to unpack the rest of the
data. One thing that we haven’t seen before is the use of * as a
field length to mean “use all characters to the end of the string.”
This is very useful when we don’t know how long our string will be.

#### Data with no end-of-record marker

Another difference that you may come across with fixed-width data is
that sometimes it comes without a defined end-of-record marker. As
both the size of each field in a record and the number of fields in a
record are well defined, we know how long each record will be. It is,
therefore, possible to send the data as a stream of bytes and leave it
up to the receiving program to split the data into individual records.

Perl, of course, has a number of ways to do this. You could read the
whole file into memory and split the data using `substr` or `unpack`, but
for many tasks the amount of data to process makes this unfeasible.

The most efficient way is to use a completely different method of
reading your data. In addition to the `<FILE>` syntax that reads data
from filehandles one record at a time, Perl supports a more
traditional syntax using the read and seek functions. The read
function takes three or four arguments. The first three are: a
filehandle to read data from, a scalar variable to read the data into,
and the maximum number of bytes to read. The fourth, optional,
argument is an offset into the variable where you want to start
writing the data (this is rarely used). read returns the number of
bytes read (which can be less than the requested number if you are
near the end of a file) and zero when there is no more data to read.

Each open filehandle has a current position associated with it
called a file pointer and read takes its data from the file pointer
and moves the pointer to the end of the data it has read. You can
also reposition the file pointer explicitly using the seek function.
seek takes three arguments: the filehandle, the offset you wish to
move to, and a value that indicates how the offset should be
interpreted. If this value is 0 then the offset is calculated from
the start of the file, if it is 1 the offset is calculated from the
current position, and if it is 2 the offset is calculated from the
end of the file. You can always find out the current position of the
file pointer by using tell, which returns the offset from the start
of the file in bytes. seek and tell are often unnecessary when
handling ASCII fixed-width data files, as you usually just read the
file in sequential order.

#### Example: reading data with no end-of-record markers using read

As an example, if our previous data file were written without
newlines, we could use code like this to read it (obviously we could
use any of the previously discussed techniques to split the record up
once we have read it):

	my $template = 'A5A20A8A6AA8';
	my $data;

	while (read STDIN, $data, 48) {
	  my @rec = unpack($template, $data);
	  print join('¦', @rec);
	  print "\n";
	}

#### Example: reading multiple record types without end-of-record markers

It is also possible to handle variable length, fixed-width records
using a method similar to this. In this case we read 3 bytes first to
get the record type and then use this to decide how many more bytes to
read on a further pass.

	my %templates = (
	  ADD => {len => 35, tem => 'a4A14a6a5a6'},
	  DEL => {len => 18, tem => 'a4A14'}
	);

	my $type;
	while (read STDIN, $type, 3) {
	  read STDIN, $data, $templates{$type}->{len};
	  my @rec = unpack($templates{$type}->{tem}, $data);
	  print "$type - ", join('¦', @rec);
	  print "\n";
	}

#### Defining record structure within the data file

I mentioned earlier that it is possible that the structure of the data
could be defined in the file. You could then write your script to be
flexible enough that it handles any changes in the structure (assuming
that the definition of the structure remains the same).

There are a number of ways to encode this metadata, most of them based
around putting the information in the first row of the file. In this
case you would read the first line separately and parse it to extract
the data. You would then use this information to build the format
string that you pass to unpack. Here are a couple of the encoding
methods that you might find—and how to deal with them.

##### Fixed-width numbers indicating column widths

In this case, the first line will be a string of numbers. You will be
told how long each number is (probably two or three digits). You can
unpack the record into an array of numbers. Each of these numbers is
the width of one field. You can, therefore, build up an unpack format
to use on the rest of the file.

	my $line = <STDIN>;

	# The metadata line
	my $width = 3;

	# The width of each number in $line;
	my $fields = length($line) / $width;
	my $meta_fmt = 'a3' x $fields;
	my @widths = unpack($meta_fmt, $line);

	my $fmt = join('', map { "A$_" } @widths);
	while (<STDIN>) {
	  my @data = unpack($fmt, $_);
	  # Do something useful with the fields in @data
	}

Notice that we can calculate the number of fields in each record by
dividing the length of the metadata record by the width of each
number in it. It might be useful to add a sanity check at that point
to ensure that this calculation gives an integer answer as it should.
Using this method our financial data file would look like this:

	005020008006001008
	00374Bloggs & Co
	19991105100103+00015000
	00375Smith Brothers
	19991106001234-00004999

The first line contains the field widths (5, 20, 8, 6, 1, and 8), all
padded out to three digit numbers.

##### Field-end markers

In this method, the first row in the file is a blank row that contains
a marker (perhaps a | character) wherever a field will end in the
following rows. In other words, our example file would look like this:

		|                 |       |     ||       |
	00374Bloggs & Co       19991105100103+00015000
	00375Smith Brothers    19991106001234-00004999

To deal with this metadata, we can split the row on the marker
character and use the length of the various elements to calculate the
lengths of the fields:

	my $line = <STDIN>; # The metadata line
	chomp $line;
	my $mark = '|'; # The field marker
	my @fields = split($mark, $line);
	my @widths = map { length($_) + 1 } @fields;
	my $fmt = join('', map { "A$_" } @widths);

	while (<STDIN>) {
	  chomp;
	  my @data = unpack($fmt, $_);
	  # Do something useful with the fields in @data
	}

Notice that we add one to the length of each element to get the
width. This is because the marker character is not included in the
array returned by the split, but it should be included in the width
of the field.

These are just two common ways to encode field structures in a
fixed-width data file. You will come across others, but it is always
a case of working out the best way to extract the required
information from the metadata record. Of course, if you have any
influence in the design of your input file, you might like to suggest
that the first line contains the format that you need to pass to
unpack—let your source system do the hard work!

### Writing fixed-width data

If you have to read fixed-width data there is, of course, a chance
that eventually you will need to write it. In this section we’ll look
at some common ways to do this.

#### Writing fixed-width data using pack

Luckily, Perl has a function which is the opposite of unpack and,
logically enough, it is called pack. pack takes a template and a list
of values and returns a string containing the list packed according to
the rules given by the template. Once again the full power of pack
will be useful when we look at binary data, but for ASCII data we will
just use the A and a template options. These options have slightly
different meanings in a pack template than the ones they have in an
unpack template.

XXX: Table
	Table 7.1 summarizes these differences.
	Table 7.1
	Meanings of A and a in pack and unpack templates
	A
	a
	pack
	Pad string with spaces
	Pad string with null characters
	unpack
	Strip trailing nulls and spaces
	Leave trailing nulls and spaces

Therefore, if we have a number of strings and wish to pack them into
a fixed-width data record, we can do something like this:

	my @strings = qw(Here are a number of strings);
	my $template = 'A6A6A3A8A4A10';

	print pack($template, @strings), "\n";

and our strings will all be space padded to the sizes given in the
pack template. There is, however, a problem padding numbers using
this method, as Perl doesn’t know the difference between text fields
and numerical fields, so you end up with numbers postpadded with
spaces (or nulls, depending on the template you use). This may, of
course, be fine for your data, but if you want to prepad numbers with
spaces then you should use the sprintf or printf functions.

#### Writing fixed-width data using printf and sprintf

These two functions do very similar things. The only difference is
that sprintf returns its results in a scalar variable, whereas printf
will write them directly to a filehandle. Both of the functions take a
format description followed by a list of values which are substituted
into the format string. The contents of the format string control how
the values appear in the final result. At each place in the format
string where you want a value to be substituted you place a format
specifier in the format `%m.nx`, where `m` and `n` control the size of
the field and `x` controls how the value should be interpreted. Full
details of the syntax for format specifiers can be found in your Perl
documentation but, for our current purposes, a small subset will
suffice.

To put integers into the string, use the format specifier `%d` (`%d`
is actually for a signed integer. If you need an unsigned value, use
`%u`) to force the field to be five characters wide, use the format
specifier `%5d`; and to prepad the field with zeroes, use `%05d`. Here
is an example which demonstrates these options:

    my @formats = qw(%d %5d %05d);
    my $num = 123;

    foreach (@formats) {
      printf "¦$_¦\n", $num;
    }

Running this code produces the following results:

    ¦123¦
    ¦
    123¦
    ¦00123¦

You can do similar things with floating point numbers using `%f`. In
this case you can control the total width of the field and also the
number of characters after the decimal point by using notation such
as `%6.2f` (for a 6 character field with two characters after the
decimal point). Here is an example of this:

    my @formats = qw(%f %6.2f %06.2f);
    my $num = 12.3;
    foreach (@formats) {
      printf "¦$_¦\n", $num;
    }

which gives the following results (notice that the default number of
decimal places is six):

     ¦12.300000¦
     ¦ 12.30¦
     ¦012.30¦

For strings we can use the format specifier %s. Again, we can use a
number within the specifier to define the size of the field. You’ll
notice from the previous examples that when the data was smaller than
the field it was to be used in, the data was right justified within
the field. With numbers, that is generally what you want (especially
when you are going to prepad the number with zeroes) but, as we’ve
seen previously, text is often left justified and postpadded with
spaces. In order to left justify the text we can prepend a minus sign
to the size specifier. Here are some examples:

 my @formats = qw(%s %10s %010s %-10s %-010s);
 my $str = 'Text';
 foreach (@formats) {
 printf "¦$_¦\n", $str;
 }

which gives the following output:

	 ¦Text¦
	 ¦
	 Text¦
	 ¦000000Text¦
	 ¦Text
	 ¦
	 ¦Text
	 ¦

Notice that we can prepad strings with zeroes just as we can for
numbers, but it’s difficult to think of a situation where that would
be useful.

#### Example: writing fixed-width data with sprintf

Putting this all together, we can produce code which can output
fixed-width financial transaction records like the ones we were
reading earlier.

XXX:

	my %rec1 = ( txnref => 374,
	cust
	=> 'Bloggs & Co',
	date
	=> 19991105,
	extref => 100103,
	dir
	=> '+',
	amt
	=> 15000 );
	my %rec2 = ( txnref => 375,
	cust
	=> 'Smith Brothers',
	date
	=> 19991106,
	extref => 1234,
	dir
	=> '-',
	amt
	=> 4999 );
	my @cols = (
	{ name
	=> 'txnref',
	width => 5,
	num
	=> 1 },
	{ name
	=> 'cust',


	width => 20,
	num
	=> 0 },
	{ name
	=> 'date',
	width => 8,
	num
	=> 1 },
	{ name
	=> 'extref',
	width => 6,
	num
	=> 1 },
	{ name
	=> 'dir',
	width => 1,
	num
	=> 0 },
	{ name
	=> 'amt',
	width => 8,
	num
	=> 1 } );
	my $format = build_fmt(\@cols);
	print fixed_rec(\%rec1, \@cols, $format);
	print fixed_rec(\%rec2, \@cols, $format);
	sub build_fmt {
	my $cols = shift;
	my $fmt;
	foreach (@$cols) {
	if ($_->{num}) {
	$fmt .= "%0$_->{width}s";
	} else {
	$fmt .= "%-$_->{width}s";
	}
	}
	return $fmt;
	}
	sub fixed_rec {
	my ($rec, $cols, $fmt) = @_;
	my @vals = map { $rec->{$_->{name}} } @$cols;
	sprintf("$fmt\n", @vals);
	}

In this program, we use an array of hashes (@cols) to define the
characteristics of each data field in our record. These
characteristics include the name of the column together with the
width that we want it to be in the output, and a flag indicating
whether or not it is a numeric field. We then use the data in this
array to build a suitable sprintf format string in the function
build\_fmt. The fixed\_rec function then extracts the relevant data
from the record (which is stored in a hash) into an array and feeds
that array to sprintf along with the format. This creates our
fixed-width record. As expected, the results of running this program
are the records that we started with at the beginning of this
chapter.

Binary data
----------

All of the data that we have looked at so far has been ASCII data.
That is, it has been encoded using a system laid down by the
American Standards Committee for Information Interchange. In this
code, 128 characters !!!FOOTNOTE  3 There are a number of extensions
to the ASCII character set which define 256 characters, but the fact
that they are nonstandard can make dealing with them problematic. !!!
have been given a numerical equivalent value from 0 to 127. For
example, the space character is number 32, the digits 0 to 9 have
the numbers 48 to 57, and the letters of the alphabet appear from 65
to 90 in upper case and from 97 to 122 in lower case. Other numbers
are taken up by punctuation marks and various control characters.

When an ASCII character is written to a file, what is actually
written is the binary version of the ASCII code for the given
character. For example the number 123 would be written to the file
as 00110001 00110010 00110011 (the binary equivalents of 49, 50,
and 51). The advantage of this type of data is that it is very easy
to write software that allows users to make sense of the data. All
you need to do is convert each byte of data into its equivalent
ASCII character. The major disadvantage is the amount of space used.
In the previous example we used 3 bytes of data to store a number,
but if we had stored the binary number 01111011 (the binary
equivalent of 123) we could have used a third of the space.

For this reason, there are a number of applications which store data
in binary format. In many cases these are proprietary binary
formats which are kept secret so that one company has a competitive
advantage over another. A good example of this is spreadsheets.
Microsoft and Lotus have their own spreadsheet file format and,
although Lotus 123 can read Microsoft Excel files, each time a new
feature is added to Excel, Lotus has to do more work to ensure that
its Excel file converter can handle the new feature. Other binary
file formats are in the public domain and can therefore be used
easily by applications from many different sources. Probably the
best example of this is in graphics files, where any number of
applications across many different platforms can happily read and
write each other’s files.

We’ll start by writing a script that can extract useful data from a
graphics file. The most ubiquitous graphics file format (especially
across the Internet) is the CompuServe *Graphics Interchange Format*
(or GIF). Unfortunately for us, this file format uses a patented data
compression technique and the owners of the patent (Unisys) are
trying to ensure that only properly licensed software is used to
create GIF files.!!!FOOTNOTE  4 You can read more about this dispute
in Lincoln Stein’s excellent article at:
http://www.webtechniques.com/archives/1999/12/webm/. !!! As Perl is
Open Source, it does not fall into this category, and you shouldn’t
use it to create GIFs. I believe that using Perl to read GIFs would
not violate the licensing terms, but to be sure we’ll look at the
*Portable Network Graphics* (PNG) format instead.

### Reading PNG files

In order to read any binary file, you will need a definition of the
format. I’m using the definition in *Programming Web Graphics with
Perl & GNU Software* by Shawn P. Wallace (O’Reilly), but you can get
the definitive version from the PNG group home page at
http://www.cdrom.com/pub/png/.

#### Reading the file format signature\

Most binary files start with a *signature*, that is a few bytes that
identify the format of the file. This is so that applications that are
reading the file can easily check that the file is in a format that
they can understand. In the case of PNG files, the first 8 bytes
always contain the hex value 0x89 followed by the string
PNG\cM\cJ\cZ\cM. In order to check that a file is a valid PNG file,
you should do something like this:

XXX: odd looking program (p140)

	my $data;
	read(PNG, $data, 8);
	die "Not a valid PNG\n" unless $data eq '\x89PNG\cM\cJ\cZ\cM';

Note that we use \x89 to match the hex number 0x89 and \cZ to match
Control-Z.

#### Reading the data chunks\

After this header sequence, a PNG file is made up of a number of
*chunks*. Each chunk contains an 8-byte header, some amount of data,
and a 4-byte trailer. Each header record contains the length in a
4-byte integer followed by four characters indicating the type of the
chunk. The length field gives you the number of bytes that you should
read from the file and the type tells you how to process it. There are
a number of different chunk types in the PNG specification, but we
will look only at the IHDR (header) chunk, which is always the first
chunk in the file and defines certain global attributes of the image.

#### Example: reading a PNG file

A complete program to extract this data from a PNG file (passed in via
`STDIN`) looks like this:

	binmode STDIN;
	my $data;
	read(STDIN, $data, 8);
	die "Not a PNG file" unless $data eq "\x89PNG\cM\cJ\cZ\cM";
	while (read(STDIN, $data, 8)) {
	my ($size, $type) = unpack('Na4', $data);
	print "$type ($size bytes)\n";
	read(STDIN, $data, $size);
	if ($type eq 'IHDR') {
	my ($w, $h, $bitdepth, $coltype, $comptype, $filtype,
	$interlscheme) =
	unpack('NNCCCCC', $data);
	print << "END";
	Width: $w, Height: $h
	Bit Depth: $bitdepth, Color Type: $coltype
	Compression Type: $comptype, Filtering Type: $filtype
	Interlace Scheme: $interlscheme
	END
	}
	read(STDIN, $data, 4);
	}

The first thing to do when dealing with binary data is to put the
filehandle that you will be reading into binary mode by calling
binmode on it. This is necessary on operating systems which
differentiate between binary and text files (these include DOS and
Windows). On these operating systems, a \cM\cJ end-of-line marker
in a text file gets translated to \n as it is read in. If this
sequence appears in a binary file, it needs to be left untouched.
Operating systems, such as UNIX, don’t make this binary/text
differentiation, so under them binmode has no effect. For reasons of
portability it is advisable to always call this function.

Having called binmode, we can then start reading our binary data. As
we saw before, the first thing that we do is to read the first 8
bytes and check them against the signature for PNG files. If it
matches we continue, otherwise we terminate the program.

We then go into a while loop, reading the header of each chunk in the
file. We read 8 bytes of raw data and convert it into something
easier to understand using unpack. Notice that we use N to extract
the 4-byte integer and a4 to extract the 4-character string. The
full set of options that you can use in an unpack format string is
given in the documentation that came with your Perl distribution. It
is in the perlfunc manual page (and notice that the full set of
options is listed under the pack function). Having established the
type of the chunk and the amount of data that it contains, we can
read in that amount of data from the file. In our program we also
display the information to the user.

The type of the chunk determines how we process the data we have
read. In our case, we are only dealing with the IHDR chunk, and that
is defined as two 4-byte integers followed by five single-character
strings. We can, therefore, split the data apart using the unpack
format NNCCCCC. The definition of these fields is in the PNG
documentation but there is a *précis* in table 7.2.

XXX: Format table

	Table 7.2\
	Elements of a PNG IHDR chunk\
	Field\
	Type\
	Description\
	Width\
	4-byte integer\
	The width of the image in pixels\
	Height\
	4-byte integer\
	The height of the image in pixels\
	Bit Depth\
	1-byte character\
	The number of bits used to represent the color of each pixel\
	Color Type\
	1-byte character\
	Code indicating how colors are encoded within the image.\
	Valid values are:\
	0: A number from 0–255 indicating the greyscale value\
	2: Three numbers from 0–255 indicating the amount of red,\
	green, and blue\
	3: A number which is an index into a color table\
	4: A greyscale value (0–255) followed by an alpha mask\
	6: An RGB triplet (as is 2, above) followed by an alpha mask\
	Compression Type\
	1-byte character\
	The type of compression used (always 0 in PNG version 1.0)\
	Filtering Type\
	1-byte character\
	The type of filtering applied to the data (always 0 in PNG ver-\
	sion 1.0)\
	Interlacing Scheme\
	1-byte character\
	The interlacing scheme used to store the data. For PNG ver-\
	sion 1.0 this is either 0 (for no interlacing) or 1 (for Adam7\
	interlacing)\

Having unpacked this data into more useable chunks we can display it.
It may be more useful to translate some of the numbers to descriptive
strings, but we won’t do that in this example. After reading and
processing the chunk data, we need only to read in the 4 bytes which
make up the chunk footer. This value can be used as a checksum
against the data in the chunk to ensure that it has not been
corrupted. In this simple example we will throw it away. Our program
then goes on to read all of the other chunks in turn. It doesn’t
process them, it simply displays the type and size of each chunk it
finds. A more complex program would need to read the PNG
specification and work out how to process each type of chunk.

#### Testing the PNG file reader\

To test this program I created a simple PNG file that was 100 pixels
by 50 pixels, containing some simple text on a white background. As
the program expects to read the PNG file from `STDIN`, I ran the program
like this: read_png.pl < test.png and the output I got looked like
this:

	IHDR (13 bytes)
	Width: 100, Height: 50
	Bit Depth: 8, Color Type: 2
	Compression Type: 0, Filtering Type: 0
	Interlace Scheme: 0
	tEXt (21 bytes)
	tIME (7 bytes)
	pHYs (9 bytes)
	IDAT (1135 bytes)
	IEND (0 bytes)

From this we can see that my file was, indeed, 100 pixels by 50
pixels. There were 8 bits per pixel and they were in RGB triplets. No
compression, filtering, or interlacing was used. After the IHDR
chunk, you can see various other chunks. The important one is the
IDAT chunk which contains the actual image data.

#### CPAN modules\

There are, of course, easier ways to get to this information than by
writing your own program. In particular, Gisle Aas has written a
module called Image::Info which is available from the CPAN. Currently
(version 0.04) the module supports PNG, JPG, TIFF, and GIF file
formats, and no doubt more will follow. Reading the source code for
this module will give you more useful insights into reading binary
files using Perl.

### Reading and writing MP3 files

Another binary file format that has been getting a lot of publicity
recently is the MP3 !!! FOOTNOTE  5 Short for MPEG3 or Motion
Pictures Experts Group—Audio Level 3. !!! file. These files store
near-CD quality sound in typically a third of the space required by
raw CD data. This has led to a whole new drain on Internet bandwidth
as people upload their favorite tracks to their web sites.

We won’t look at reading or writing the actual audio data in an MP3
file (encoding audio data is a large enough field to deserve several
books of description), but we will look at the ID3 data which is
stored at the end of an MP3 file. The ID3 tags allow you to store
useful information about the sounds contained in the file within the
file itself. This includes obvious fields such as the artist, album,
track name, and year of release, together with more obscure data like
the genre of the track and the copyright and distribution
information.

Chris Nandor has written a module which allows you to read and write
these data fields. The module is called MPEG::MP3Info and it is
available from the CPAN. Using the module is very simple. Here is a
sample program which displays all of the ID3 data that it can find in
a given MP3 file:

	use MPEG::MP3Info;\
	my \$file = shift;\
	my \$tag = get\_mp3tag(\$file);\
	my \$info = get\_mp3info(\$file);\
	print "Filename: \$file\\n";\
	print "MP3 Tags\\n";\
	foreach (sort keys %\$tag) {\
	print "\$\_ : \$tag-\>{\$\_}\\n";\
	}\
	print "MP3 Info\\n";\
	foreach (sort keys %\$info) {\
	print "\$\_ : \$info-\>{\$\_}\\n";\
	}\

Notice that there are two separate parts of the ID3 data. The data
returned in $tag is the data about the sound contained in the
file—like track name, artist, and year of release. The data returned
in $info tend to be more physical data about the actual data in the
file—the bit-rate, frequency, and whether the recording is stereo or
mono. For this reason, the module currently (and I’m looking at
version 0.71) contains a set\_mp3tag function, but not a set\_mp3info
function. It is likely that you’ll have good reasons to change the
ID3 tags which defined the track and artist, but less likely that
you’ll ever need to change the physical recording parameters. There
is also a remove\_mp3tag function which removes the ID3 data from the
end of the file.

As with Image::Info which we discussed earlier, it is very
instructive to read the code of this module as it will give you many
useful ideas on the best way to read and write your binary data.

Further information
----------

This chapter has discussed a number of built-in Perl functions. These
include pack, unpack, read, printf, and sprintf. For more information
about any built-in Perl function see the perldoc perlfunc manual
page. The list of type specifiers supported by sprintf and printf is
system-dependent, so you can get this information from your system
documentation.

The Image::Info and MPEG::MP3Info modules are both available from the
CPAN. Having installed them, you will be able to read their full
documentation by typing perldoc Image::Info or perldoc MPEG::MP3Info
at your command line.

Summary
----------

*  The easiest way to split apart a fixed-width data record is by using the unpack function.

*  Conversely, the easiest way to create a fixed-width data record is by using the pack function.

*  If your data doesn’t have distinct end-of-record markers, you can read a certain number of bytes from your input data stream using the read function.

*  Once you have used the binmode function on a binary data stream it can be processed using exactly the same techniques as a text data stream.
