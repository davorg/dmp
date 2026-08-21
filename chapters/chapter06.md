Chapter 6: Record-oriented data
===============================

What this chapter covers:

*  Reading, writing, and processing simple record-oriented data

*  Caching data

*  Currency conversion

*  The comma separated value format

*  Creating complex data records

*  Problems with date fields

A very large proportion of the data that you will come across in data
munging tasks will be record oriented. In this chapter we will take a
look at some common ways to deal with this kind of data.

Simple record-oriented data
---------------------------

We have already seen examples of simple record-oriented data. The CD
data file that we examined in previous chapters had one line of data
for each CD in my collection. Each of these lines of data is a
record. As we will see later, a record can be larger or smaller than
one line, but we will begin by looking in more detail at files where
each line is one record.

### Reading simple record-oriented data

Perl makes it very easy to deal with record-oriented data,
particularly simple records of the type we are discussing here. We
have seen before the idiom where you can read a file a line at a time
using a construct like

	while (<FILE>) {
	  chomp; # remove newline
	  # each line in turn is assigned to $_
	}

Let’s take a closer look and see what Perl is doing here to make life
easier.

The most important part of the construct is the use of `<FILE>` to read
data from the filehandle `FILE` which has presumably been assigned to a
file earlier in the program by a call to the open function. This file
input operator can return two different results, depending on whether
it is used in scalar context or array context.

When called in a scalar context, the file input operator returns the
next record from the filehandle. This begs the obvious question of
what constitutes a record. The answer is that input records are
separated by a sequence of characters called (logically enough) the
input record separator. This value is stored in the variable `$/`. The
default value is a newline `\n` (which is translated to the appropriate
actual characters for the specific operating system), but this can be
altered to any other string of characters. We will look at this usage
in more detail later, but for now the default value will suffice.

When called in an array context, the file input operator returns a
list in which each element is a record from the input file. You can,
therefore, call the file input operator in one of these two ways:

	my $next_line = <FILE>;
	my @whole_file = <FILE>;

In both of these examples it is important to realize that each
record—whether it is the record stored in `$next_line` or one of the
records in `@whole_file` will still contain the value of `$/` at the
end. Often you will want to get rid of this and the easiest way to do
it is by using the chomp function.
[chomp](https://perldoc.perl.org/functions/chomp) is passed either a
scalar or an array and removes the value of `$/` from the end of the
scalar or each element of the array. If no argument is passed to
[chomp](https://perldoc.perl.org/functions/chomp) then it works on
`$_`.

In versions of Perl before Perl 5, the [chomp](https://perldoc.perl.org/functions/chomp) function
did not exist. Instead we had to use a function called [chop](https://perldoc.perl.org/functions/chop), which
simply removed the last character from a string without checking what
it was. As this is still an occasionally useful thing to do to a
string, [chop](https://perldoc.perl.org/functions/chop) is still available in Perl, but most of the time [chomp](https://perldoc.perl.org/functions/chomp) is
more appropriate.

#### Reading data a record at a time (from first principles)

Now that we understand a little more about the file input operator
and [chomp](https://perldoc.perl.org/functions/chomp), let’s
see if we can build our standard data munging input construct from first
principles.

A first attempt at processing each line in a file might look something
like this:

	my $line;
	while ($line = <FILE>) {
	  chomp $line;
	  …
	}

This is a good start, but it has a subtle bug in it. The conditional
expression in the while loop is checking for the truth of the scalar
variable `$line`. This variable is set from the next line taken from
`FILE`. Generally this is fine, but there are certain conditions when a
valid line in a file can evaluate to false. The most obvious of these
is when the final line in a file contains the value 0 (zero) and has
no end of line characters after it (perhaps the very last line). In this
case, the variable `$line` will contain the value 0 which will
evaluate as false and the final line of the file will not be
processed.

Although this bug is a little obscure, it is still worthwhile finding
a solution that doesn’t exhibit this problem. This is simple enough
to do by checking that the line is defined instead of evaluating to
true. The contents of a variable are said to be defined if they are
not the special Perl value `undef`. Any variable that contains a value
that evaluates to false will still be defined. Whether or not a value
is defined can be tested using the [defined](https://perldoc.perl.org/functions/defined) function. The file input
operator returns `undef` when the end of the file is reached. We can
therefore rewrite our first attempt into something like this:

	my $line;
	while (defined($line = <FILE>)) {
	  chomp $line;
	  …
	}

and this will exhibit all of the behavior that we need. There are
still a couple of improvements that we can make, but these are more
about making the code Perlish than about fixing bugs.

The first of the changes is to make use of the Perl default variable
`$_`. A lot of Perl code can be made more streamlined by using `$_`.
In this case it makes a small amount of difference. We no longer need
to define `$line` and we can make use of the fact that
[chomp](https://perldoc.perl.org/functions/chomp) works on `$_` by
default. Our code will now look like this:

	while (defined($_ = <FILE>)) {
	  chomp;
	  …
	}

The last piece of optimization is one that you wouldn’t be able to
guess at, as it uses a piece of syntactic sugar that was put in by
the authors of Perl when they realized what a common task this would
be. If the file input operator is the only thing that is in the
conditional expression of a while loop, then the result of the
operator is magically assigned to the `$_` variable and the resulting
value is checked to see that it is defined (rather than checking that
it is true). This means that you can write:

	while (<FILE>)) {
	  chomp;
	  …
	}

at which point we are back with our original code (but, hopefully,
with a deeper understanding of the complexities beneath the surface
of such simple looking code).

Notice that this final optimization is dependent on two things being
true:

First, the file input operator must be the only thing in the conditional
expression, so you can’t write things like

	while (<FILE> and $_ ne 'END') { # THIS DOESN'T WORK!
	  …
	}

Second, the conditional expression must be part of a `while` loop, so you
can’t write things like

	if (<FILE>) { # THIS DOESN'T WORK EITHER!
	  print;
	} else {
	  print "No data\n";
	}

#### Counting the current record number

While looping through a file like this it is often useful to know
which line you are currently processing. This useful information is
stored in the `$.` variable, the current line number in the filehandle
that you read most recently. The value is reset when the filehandle is
closed, which means that this works:

	open FILE, 'input.txt' or die "Can't open input file: \$!\\n";

	while (<FILE>) {
	  # do stuff
	}

	print "$. records processed.\n";
	close FILE;

but the following code is wrong as it will always print zero.

	# THIS CODE DOESN'T WORK
	open FILE, "input.txt" or die "Can't open input file: $!\n";
	while (<FILE>) {
	  # do stuff
	}

	close FILE;
	print "$. records processed.\n";

In many of these examples, I have moved away from using `STDIN`,
simply to indicate that these methods will work on any filehandle. To
finish this section, here is a very short example using `STDIN` that
will add line numbers to any file passed to it.

	#!/usr/local/bin/perl
	use strict;
    use warnings;

	print "$.: $_" while <STDIN>;

### Processing simple record-oriented data

So now that we know how to get our records from the input stream
(either one at a time or all together in an array) what do we do with
them? Of course, the answer to that question depends to a great
extent on what your end result should be, but here are a few ideas.

#### Extracting data fields

Chances are that within your record there will be individual data
items (otherwise known as fields) and you will need to break up the
record to access these fields. Fields can be denoted in a record in a
number of ways, but most methods fall into one of two camps. In one
method the start and end of a particular field is denoted by a
sequence of characters that won’t appear in the fields themselves.
This is known as delimited or separated data.

*Separated data* has a character sequence between each field and
*delimited data* has a character sequence at the start and end of each
field. In practical terms, however, the methods for dealing with them
are very similar and many people tend to use the terms as if they are
interchangeable.

In the other method each field is defined to take up a certain number
of characters and is space—or zero—padded if it is less than the
defined size. This is known as fixed-width data. We will cover
fixed-width data in more detail in the [next chapter](ch011.xhtml) and
for now will limit ourselves to separated and delimited data.

We have seen separated data before. The CD example that we have looked
at in previous chapters is an example of a tab-separated data file. In
the file each line represents one CD, and within a line the various
fields are separated by the tab character. An obvious way to deal with
this data is the one that we used before, *i.e.*, using split to
separate the record into individual fields like this:

	my $record = <STDIN>;
	chomp $record;
	my @fields = split(/\t/, $record);

The fields will then be in the elements of `@fields`. Often, a more
natural way to model a data record is by using a hash. For example,
to build a `%cd` hash from a record in our CD file, we could do
something like this:

	my $record = <STDIN>;
	chomp $record;
	my %cd;
	($cd{artist}, $cd{title}, $cd{label}, $cd{year})
	  = split (/\t/, $record);

We can then access the individual fields within the record using:

	my $label = $cd{label};
	my $title = $cd{title};

and so on.

Within the actual CD file input code from [Chapter 3](ch006.xhtml) we simplified
this code slightly by writing it like this:

	my @fields = qw/artist title label year/;
	my $record = <FILE>;
	chomp $record;
	my %cd;
	@cd{@fields} = split(/\t/, $record);

In this example we make use of a hash slice to make assigning values
to the hash much easier. Another side effect is that it makes
maintenance a little easier as well. If a new field is added to the
input file, then the only change required to the input routine is to
add another element to the `@fields` array.

We now have a simple and efficient way to read in simple
record-oriented data and split each record into its individual fields.

### Writing simple record-oriented data

Of course, having read in your data and carried out suitable data
munging, you will next need to output your data in some way. The
obvious choice is to use
[print](https://perldoc.perl.org/functions/print), but there are other
options and even [print](https://perldoc.perl.org/functions/print) has
a few subtleties that will make your life easier.

#### Controlling output—separating output records

In the same way that Perl defines a variable (`$/`) that contains the
input record separator, it defines another variable (`$\`) which
contains the output record separator. Normally this variable is set to
`undef` which leaves you free to control exactly where you output the
record separator. If you set it to another value, then that value will
be appended to the end of the output from each [print](https://perldoc.perl.org/functions/print) statement. If you
know that in your output file each record must be separated by a
newline character, then instead of writing code like this:

	foreach (@output_records) {
	  print "$_\n";
	}

you can do something like this:

	{
	  local $\ = "\n";
	  foreach (@output_records) {
	    print;
	  }
	}

(Notice how we’ve localized the change to `$\` so that we don’t
inadvertently break any [print](https://perldoc.perl.org/functions/print) statements elsewhere in the program.)

Generally people don’t use this variable because it isn’t really any
more efficient.

#### Controlling output—printing lists of items

Other variables that are much more useful are the output field
separator (`$,`) and the output list separator (`$"`). The output field
separator is printed between the elements of the list passed to a
print statement and the output list separator is printed between the
elements of a list that is interpolated in a double quoted string.
These concepts are dangerously similar so let’s see if we can make it
a little clearer.

In Perl the [print](https://perldoc.perl.org/functions/print) function
works on a list. This list can be passed to the function in a number
of different ways. Here are a couple of examples:

	print 'This list has one element';
	print 'This', 'list', 'has', 'five', 'elements';

In the first example the list passed to
[print](https://perldoc.perl.org/functions/print) has only one
element. In the second example the list has five elements that are
separated by commas. The output field separator (`$,`) controls what
is printed between the individual elements. By default, this variable
is set to the empty string (so the second example above prints
`Thislisthasfiveelements`). If we were to change the value of `$,` to a
space character before executing the print statement, then we would
get something a little more readable. The following:

	$, = ' ';
	print 'This', 'list', 'has', 'five', 'elements';

produces the output

	This list has five elements

This can be useful if your output data is stored in a number of
variables. For example, if our CD data was in variables called
`$band`, `$title`, `$label`, and `$year` and we wanted to create a
tab-separated file, we could do something like this:

	$\ = "\n";
	$, = "\t";
	print $band, $title, $label, $year;

which would automatically put a tab character between each field and
a newline character on the end of the record.

Another way that a list is often passed to [print](https://perldoc.perl.org/functions/print) is in an array
variable. You will sometimes see code like this:

	my @list = qw/This is a list of items/;
	print @list;

in which case the elements of `@list` are printed with nothing
separating them (`Thisisalistofitems`). A common way to get round this
is to use [join](https://perldoc.perl.org/functions/join):

	my @list = qw/This is a list of items/;
	print join(' ', @list);

which will put spaces between each of the elements being printed. A
more elegant way to handle this is to use the list separator variable
(`$"`). This variable controls what is printed between the elements of
an array when the array is in double quotes. The default value is a
space. This means that if we change our original code to

	my @list = qw/This is a list of items/;
	print "@list";

then we will get spaces printed between the elements of our list. In
order to print the data with tabs separating each record we simply
have to set `$"` to a tab character (`\t`). In [Chapter 3](ch006.xhtml) when we were
reading in the CD data file we stored the data in an array of hashes.
An easy way to print out this data would be to use code like this:

	my @fields = qw/name title label year/;

	local $" = "\t";
	local $\ = "\n";

	foreach (@CDs) {
	  my %CD = %$_;
	  print "@CD{@fields}";
	}

#### Controlling output—printing to different filehandles

Recall that the syntax of the [print](https://perldoc.perl.org/functions/print) statement is one of the following:

	print;
	print LIST;
	print FILEHANDLE LIST;

In the first version the contents of `$_` are printed to the default
output filehandle (usually `STDOUT`). In the second version the
contents of `LIST` are printed to the default output filehandle. In
the third version the contents of `LIST` are printed to `FILEHANDLE`.

Notice that I said that the default output filehandle is *usually*
`STDOUT`. If you are doing a lot of printing to a different filehandle,
then it is possible to change the default using the [select](https://perldoc.perl.org/functions/select) function. If you call [select](https://perldoc.perl.org/functions/select)
with no parameters, it will return the name of the currently selected
output filehandle, so

	print select;

will normally `print main::STDOUT`. If you call select with the name of
a filehandle, it will replace the current default output filehandle
with the new one. It returns the previously selected filehandle so
that you can store it and reset it later. If you needed to write a lot
of data to a particular file, you could use code like this:

	open FILE, '>out.txt' or die "Can't open out.txt: $!";
	my $old = select FILE;

	foreach (@data) {
	  print;
	}
	select $old;

Between the two calls to
[select](https://perldoc.perl.org/functions/select), the default
output filehandle is changed to be `FILE` and all
[print](https://perldoc.perl.org/functions/print) statements without a
specific filehandle will be written to `FILE`. Notice that when we
have finished we reset the default filehandle to whatever it was
before we started (we stored this value in `$file`). You shouldn’t
assume that the default filehandle is `STDOUT` before you change it,
as some other part of the program may have changed it already.

Another variable that is useful when writing data is `$|`. Setting this
variable to a nonzero value will force the output buffer to be
flushed immediately after every [print](https://perldoc.perl.org/functions/print) (or [write](https://perldoc.perl.org/functions/write)) statement. This has
the effect of making the output stream look as if it were unbuffered.
This variable acts on the currently selected output filehandle. If
you want to unbuffer any other filehandle, you will need to select
it, change the value of `$|`, and then reselect the previous filehandle using code like this:

	my $file = select FILE;
	$| = 1;
	select $file;

While this works, it isn’t as compact as it could be, so in many Perl
programs you will see this code instead:

	select((select(FILE), $| = 1)[0]);

This is perhaps one of the strangest looking pieces of Perl that
you’ll come across but it’s really quite simple if you look closely.

The central part of the code is building a list. The first element of
the list is the return value from `select(FILE)`, which will be the
previously selected filehandle. As a side effect, this piece of code
selects `FILE` as the new default filehandle. The second element of
the list is the result of evaluating `$| = 1`, which is always 1. As a
side effect, this code will unbuffer the current default filehandle
(which is now `FILE`). The code now takes the first element of this
list (which is the previously selected filehandle) and passes that
to [select](https://perldoc.perl.org/functions/select), thereby returning the default filehandle to its previous
state.

### Caching data

One common data munging task is translating data from one format to
another using a lookup table. Often a good way to handle this is to
cache data as you use it, as the next example will demonstrate.

#### Example: currency conversion

A good example of data translation would be converting data from one
currency to another. Suppose that you were given a data file with
three columns, a monetary amount, the currency that it is in, and the
date that should be used for currency conversions. You need to be able
to present this data in any of a hundred or so possible currencies.
The daily currency rates are stored in a database. In pseudocode, a
first attempt at this program might look something like this:

	Get target currency
	For each data row
	  Split data into amount, currency, and date
	  Get conversion rate between source and target currencies on given date
	  Multiply amount by conversion rate
	  Output converted amount
	Next

This would, of course, do the job but is it the most efficient way of
doing it? What if the source data was all in the same currency and
for the same date? We would end up retrieving the same exchange rate
from the database each time. Maybe we should read all of the possible
exchange rates in at the start and store them in memory. We would
then have very fast access to any exchange rate without having to go
back to the database. This option would work if we had a reasonably
small number of currencies and a small range of dates (perhaps we are
only concerned with U.S. dollars, Sterling, and Deutschmarks over the
last week). For any large number of currencies or date range, the
overhead of reading them all into memory would be prohibitive. And,
once again, if the source data all had the same currency and date
then we would be wasting a lot of our time.

The solution to our problem is to cache the exchange rates that we
have already read from the database. Look at this script:

	#!/usr/bin/perl

    use strict;
    use warnings;

	my $target_curr = shift;
	my %rates;
	while (<STDIN>) {
	  chomp;
	  my ($amount, $source_curr, $date) = split(/\t/);
	  $rates{"$source_curr|$target_curr|$date"} ||=
	    get_rate($source_curr,
	             $target_curr,
	             $date);
	  $amount *= $rates{"$source_curr|$target_curr|$date"};
	  print "$amount\t$target_curr\t$date\n";
	}

In this script we assume that the `get_rate` function goes to the
database and returns the exchange rate between the source and target
currencies on the given date. We have introduced a hash which caches
the return values from this function. Remember that in Perl

	$a ||= $b;

means the same thing as

	$a = $a || $b;

and also that the Perl `||` operator is short-circuiting, which means
that the expression after the operator is only evaluated if the
expression before the operator is false. Bearing this in mind, take
another look at this line of the above script:

	  $rates{"$source_curr|$target_curr|$date"} ||=
	    get_rate($source_curr,
	             $target_curr,
	             $date);

The first time that this line is reached, the `%rates` hash is empty.
The `get_rate` function is therefore called and the exchange rate that
is returned is written into the hash with a key made up from the
three parameters. The next time that this line is reached with the
same combination of parameters, a value is found in the hash and the
`get_rate` function does not get called.

You might notice that we’re checking the *value* in the hash rather
than the *existence* of a value. This may cause a problem if the value
can legitimately be zero (or any other value which is evaluated as
false—the string “0”, the empty string, or the value `undef`). In this
case the existence of a zero exchange rate may cause a few more
serious problems than a bug in a Perl script, so I think that we can
safely ignore that possibility. You may need to code around this
problem.

#### Taking caching further—Memoize.pm

This trick is very similar to the Orcish Manoeuvre which we saw when
we were discussing sorting techniques in [Chapter 3](ch006.xhtml). It
is, however, possible to take things one step further. On the CPAN
there is a module called [Memoize](http://metacpan.org/pod/Memoize)
which was written by Mark-Jason Dominus. This module includes a
function called memoize which will automatically wrap caching
functionality around any function in your program. We would use it in
our currency conversion script like this:

	#!/usr/bin/perl –w
	use Memoize;
	memoize 'get_rate';

	my $target_curr = shift;
	while (<STDIN>) {
	  chomp;
	  my ($amount, $source_curr, $date) = split(/\t/);
	  $amount *= get_rate($source_curr, $target_curr, $date);
	  print "$amount\t$target_curr\t$date\n";
	}

Notice how the introduction of [Memoize](http://metacpan.org/pod/Memoize) actually simplifies the code.
What [Memoize](http://metacpan.org/pod/Memoize) does is it replaces any call to a memoized function
(`get_rate` in our example) with a call to a new function. This new
function checks an internal cache and calls the original function only
if there is not an appropriate cached value already available. [An
article](https://www.foo.be/docs/tpj/issues/vol4_1/tpj0401-0011.html) explaining these concepts in some detail appeared in issue 13
([Vol. 4, No. 1](https://www.foo.be/docs/tpj/issues/vol4_1/ewtoc.html)) Spring 1999 of *The Perl Journal*.

Not every function call is a suitable candidate for caching or
memoization but, when you find one that is, you can see a remarkable
increase in performance.

Comma-separated files
---------------------

A very common form of record-oriented data is the comma-separated
value (CSV) format. In this format each record is one line of the
data file and within that record each field is separated with commas.
This format is often used for extracting data from spreadsheets or
databases.

### Anatomy of CSV data

At first glance it might seem that there is nothing particularly
difficult about dealing with comma-separated data. The structure is
very similar to the tab or pipe separated files that we have looked
at before. The difference is that while tab and pipe characters are
relatively rare in many kinds of data, the comma can quite often
appear in data records, especially if the data is textual. To get
around these problems there are a couple of additions to the CSV
definition. These are:

*  A comma should not be classed as a separator if it is in a string that is enclosed in double quotes.

*  Within a double quoted string, a double quote character is represented by two consecutive double quotes.

Suddenly things get a bit more complex. This means that the following
is a valid CSV record:

	"Cross, Dave",07/09/1962,M,"Field with ""embedded"" quotes"

We can’t simply split this data on commas, as we would have done
before because the extra comma in the first field will generate an
extra field. Also, the double quotes around the first and last fields
are not part of the data and need to be stripped off and the doubled
double quotes in the last field need to be converted to single double
quotes!

### Text::CSV\_XS

Fortunately, this problem has already been solved for you. On the CPAN
there is a module called
[Text::CSV_XS](http://metacpan.org/pod/Text::CSV_XS) which will
extract the data from CSV files and will also generate CSV records
from your data. The best way to explain how it works is to leap right
in with an example or two. Suppose that we had a CSV file which
contained data like the previous example line. The code to extract and
print the data fields would look like this:

	use Text::CSV_XS;

	my $csv = Text::CSV->new;

	$csv->parse(<STDIN>);
	my @fields = $csv->fields;

	local $" = '|';
	print "@fields\n";

Assuming the input line above, this will print:

	Cross, Dave|07/09/1962|M|Field with "embedded" quotes

Notice the use of $" to print pipe characters between the fields.
Text::CSV\_XS also works in reverse. It will create CSV records from
your data.

As an example, let’s rebuild the same data line from the individual
data fields.

	my @new_cols = ('Cross, Dave', '07/09/1962', 'M',
	                'Field with "embedded" quotes');
	$csv->combine(@new_cols);

	print $csv->string;

This code prints:

	"Cross, Dave",07/09/1962,M,"Field with ""embedded"" quotes"

which is back to our original data.

The important functions in Text:CSV are therefore:

*  `new`—Creates a CSV object through which all other functions can be called.

*  `parse($csv_data)`—Parses a CSV data string that is passed to it. The extracted columns are stored internally within the CSV object and can be accessed using the `fields` method.

*  `fields`—Returns an array containing the parsed CSV data fields.

*  `combine(@fields)`—Takes a list of data fields and converts them into a CSV data record. The CSV record is stored internally within the CSV object and can be accessed using the string method.

*  `string` —Returns a string which is the last created CSV data record. With this in mind, it is simple to create generic CSV data reading and writing routines.

<!-- end of list -->

	use Text::CSV;
	sub read_csv {
	  my $csv = Text::CSV->new;

	  my @data;

	  while (<STDIN>) {
	    $csv->parse($_);
	    push @data, [$csv->fields];
	  }

	  return \@data;
	}

	sub write_csv {
	  my $data = shift;
	  my $csv = Text::CSV->new;
	  foreach (@$data) {
	    $csv->combine(@$_);
	    print $csv->string;
	  }
	}

 These functions would be called from within a program like this:

	my $data = read_csv;

	foreach (@$data) {
	  # Do something to each record.
	  # Individual fields are accessed as
	  # $_->[0], $_->[1], etc …
	}

	write_csv($data);

Complex records
---------------

All of the data we have seen up to now has had one line per record,
but as I hinted earlier it is quite possible for data records to span
more than one line in a data file. Perl makes it almost as simple to
deal with nearly any kind of data. The secret to handling more
complex data records is to make good use of the Perl variables that
we mentioned in previous sections.

### Example: a different CD file

Imagine, for example, if our CD file was in a slightly different
format, like this:

	Name: Bragg, Billy
	Title: Workers' Playtime
	Label: Cooking Vinyl
	Year: 1987
	%%
	Name: Bragg, Billy
	Title: Mermaid Avenue
	Label: EMI
	Year: 1998
	%%
	Name: Black, Mary
	Title: The Holy Ground
	Label: Grapevine
	Year: 1993
	%%
	Name: Black, Mary
	Title: Circus
	Label: Grapevine
	Year: 1996
	%%
	Name: Bowie, David
	Title: Hunky Dory
	Label: RCA
	Year: 1971
	%%
	Name: Bowie, David
	Title: Earthling
	Label: EMI
	Year: 1997

In this case the data is exactly the same, but a record is now spread
over a number of lines. Notice that the records are separated by a
line containing the character sequence `%%`, a
surprisingly common record separator, due to its use as the record
separator in the data files read by the UNIX `fortune` program. This
will be our clue in working out the best way to read these records.
Earlier we briefly mentioned the variable `$/` which defines the input
record separator. By setting this variable to an appropriate value we
can get Perl to read the file one whole record at a time. In this case
the appropriate value is `\n%%\n`. We can now read in records like this:

	local $/ = "\n%%\n";
	while (<STDIN>) {
	  chomp;
	  print "Record $. is\n$_";
	}

Remember that when Perl reads to the next occurrence of the input
record separator, it includes the separator character sequence in the
string that it returns. We therefore use [chomp](https://perldoc.perl.org/functions/chomp) to remove that
sequence from the string before processing it.

So now we have the record in a variable. How do we go about
extracting the individual fields from within the records? This is
relatively easy as we can go back to using [split](https://perldoc.perl.org/functions/split) to separate the
fields. In this case the field separator is a newline character so
that is what we need to split on.

	local $/ = "\n%%\n";
	while (<STDIN>) {
	  chomp;
	  print join('|', split(/\n/)), "\n";
	}

This code will print each of the records on one line with the fields
separated by a pipe character. We are very close to having all of the
fields in a form that we can use, but there is one more step to take.

#### Making use of the extra data

One difference between this format and the original (one record per
line) format for the CD file is that the individual fields are now
labeled. We need to lose these labels, but we can first make good use
of them. Eventually we want each of our records to end up in a hash.
The values of the hash will be the values of the data fields, but what
are the keys? In previous versions of the CD input routines we have
always hard-coded the names of the data fields, but here we have been
given them. Let’s use them to create the keys of our hash. This will
hopefully become clearer when you see this code:

	1: $/ = "\n%%\n";
	2:
	3: my @CDs;
	4:
	5: while (<STDIN>) {
	6:   chomp;
	7:   my (%CD, $field);
	8:
	9:   my @fields = split(/\n/);
	10:  foreach $field (@fields) {
	11:    my ($key, $val) = split (/:\s*/, $field, 2);
	12:    $CD{lc $key} = $val;
	13:  }
	14:
	15:  push @CDs, \%CD;
	16: }

Let’s examine this code line by line.

Line 1 sets the input record separator to be `\n%%\n`.

Line 3 defines an array variable that we will use to store the CDs.

Line 5 starts the while loop which reads each line from `STDIN` in to
`$_`.

Line 6 calls chomp to remove the `\n%%\n` characters from the end of `$_`.

Line 7 defines two temporary variables. `%CD` will store the data for
one CD and `$field` will be used as temporary storage when processing
the fields.

Line 9 creates an array `@fields` which contains each of the fields in
the record, split on the newline character. Notice that [split](https://perldoc.perl.org/functions/split) throws
away the separator character so that the fields in the array do not
have newline characters at the end of them.

Line 10 starts a `foreach` loop which processes each field in the
record in turn. The field being processed is stored in `$field`.

Line 11 splits the field into its key and its value, assigning the
results to `$key` and `$value`. Note that the regular expression that we
split on is `/:\s*/`. This matches a colon followed by zero or more
white space characters. In our sample data, the separator is always a
colon followed by exactly one space, but we have made our script a
little more flexible. We also pass a limit to split so that the list
returned always contains two or fewer elements.

Line 12 assigns the value to the key in the `%CD` hash. Notice that we
actually use the lowercase version of `$key`. Again this just allows us
to cope with a few more potential problems in the input data.

Line 13 completes the `foreach` loop. At this point the `%CD` hash should
have four records in it.

Line 15 pushes a reference to the `%CD` onto the `@CDs` array.

Line 16 completes the `while` loop. At this point the `@CDs` array will
contain a reference to one hash for each of the CDs in the collection.

### Special values for $/

There are two other commonly used values for `$/`—`undef` and the empty
string. Setting `$/` to `undef` puts Perl into “slurp mode.” In this mode
there are no record separators and the whole input file will be read
in one go. Setting `$/` to the empty string puts Perl into “paragraph
mode.” In this mode, records are separated by one or more blank
lines. Note that this is not the same as setting `$/` to `\n\n`. If a
file has two or more consecutive blank lines then setting `$/` to `\n\n`
will give you extra empty records, whereas setting it to the empty
string will soak up any number of blank lines between records. There
are, of course, times when either of these behaviors is what is
required.

You can also set `$/` to a reference to a scalar (which should contain
an integer). In this case Perl will read that number of bytes from
the input stream. For example:

	local $/ = \1024;
	my $data = <DATA>;

will read in the next kilobyte from the filehandle `DATA`. This idiom
is more useful when reading binary files.

One thing that you would sometimes like to do with `$/` is set it to a
regular expression so that you can read in records that are delimited
by differing record markers. Unfortunately, you must set `$/` to be a
fixed string, so you can’t do this. The best way to get around this
is to read the whole file into a scalar variable (by setting `$/` to
`undef`) and then use [split](https://perldoc.perl.org/functions/split) to break it up into an array of records.
The first parameter to [split](https://perldoc.perl.org/functions/split) is interpreted as a regular expression.

Special problems with date fields
---------------------------------

It is very common for data records to contain dates (and times).
Unfortunately, Perl’s date handling seems to be one of the areas that
confuses a large number of people, which is a shame, because it is
really very simple. Let’s start with an overview of how Perl handles
dates.

### Built-in Perl date functions

As far as Perl is concerned, all dates are measured as a number of
seconds since the epoch. That sounds more complex than it is. The
epoch is just a date and time from which all other dates are
measured. This can vary from system to system, but on many modern
computer systems (including all UNIX systems) the epoch is defined as
00:00:00 GMT on Thursday, Jan. 1, 1970. The date as I’m writing this
is 943011797, which means that almost a billion seconds have passed
since the beginning of 1970.

#### Getting the current date and time with time functions

You can attain the current date and time in this format using the time
function. I generated the number in the last paragraph by running this
at my command line:

	perl -e "print time";

This can be useful for calculating the time that a process has taken
to run. You can write something like this:

	my $start = time;
	# Do lots of clever stuff
	my $end = time;
	print "Process took ", $end - $start, " seconds to run.";

#### More readable dates and times with localtime

This format for dates isn’t very user friendly, so Perl supplies the
[localtime](https://perldoc.perl.org/functions/localtime) function to convert these values into readable formats,
adjusted for your current time zone ([gmtime](https://perldoc.perl.org/functions/gmtime) does the same as [localtime](https://perldoc.perl.org/functions/localtime) but doesn’t make
time zone adjustments).  [localtime](https://perldoc.perl.org/functions/localtime) takes
one optional argument, which is the number of seconds since the epoch.
If you don’t pass this argument it calls time to get the current time.
[localtime](https://perldoc.perl.org/functions/localtime) returns different things depending on whether it is called
in scalar or array context. In a scalar context it returns the date in
a standard format. You can see this by running

	perl -e "print scalar localtime"

at your command line. Notice the use of scalar to force a scalar
context on the function call, as [print](https://perldoc.perl.org/functions/print) gives its arguments an array
context. To find when exactly a billion seconds will have passed
since the epoch you can run:

	perl -e "print scalar localtime(1\_000\_000\_000)"

(which prints “Sun Sep 9 01:46:40 2001” on my system) and to find out
when the epoch is on your system use:

	perl -e "print scalar localtime(0)"

In an array context, localtime returns an array containing the
various parts of the date. The elements of the array are:

*  the number of seconds (0–60) (the 61st second is there to handle leap seconds)

*  the number of minutes (0–59)

*  the hour of the day (0–23)

*  the day of the month (1–31)

*  the month of the year (0–11)

*  the year, as the number of years since 1900.

*  the day of the week (0 is Sunday and 6 is Saturday)

*  the day of the year

*  a Boolean flag indicating whether daylight savings time is in effect.

Some of these fields cause a lot of problems.

The month and the day of the week are given as zero-based numbers.
This is because you are very likely to convert these into strings
using an array of month or day names.

The year is given as the number of years since 1900. This is
well-documented and has always been the case, but the fact that until
recently this has been a two-digit number has led many people to
believe that it returns a two-digit year. This has led to a number of
broken scripts gaining a great deal of currency and it is common to
see scripts that do something like this:

	my $year = (localtime)[5];
	$year = "19$year"; # THIS IS WRONG!

or (worse)

	$year = ($year < 50) ? "20$year" : "19$year"; # THIS IS WRONG!

The correct way to produce a date using
[localtime](https://perldoc.perl.org/functions/localtime) is to do
something like this:

	my @months = qw/January February March April May June July August
	                September October November December/;
	my @days = qw/Sunday Monday Tuesday Wednesday Thursday Friday Saturday/;

	my @now = localtime;

	$now[5] += 1900;

	my $date = sprintf '%s %02d %s %4d, %02d:%02d:%02d',
	                   $days[$now[6]], $now[3], $months[$now[4]], $now[5],
	                   $now[2], $now[1], $now[0];

As hinted in the code above, if you don’t need all of the date
information, it is simple enough to use an array slice to get only
the parts of the array that you want.

These are all valid constructions:

	my $year = (localtime)[5];
	my ($d, $m, $y) = (localtime)[3 .. 5];
	my ($year, $day_no) = (localtime)[5, 7];

#### Getting the epoch seconds using timelocal

It is therefore easy enough to convert the return value from time to a
readable date string. It would be reasonable to want to do the same in
reverse. In Perl you can do that by using the `timelocal` function. This
function is not a Perl built-in function, but is included in the
standard Perl library in the module [Time::Local](http://metacpan.org/pod/Time::Local).

To use `timelocal`, you pass it a list of time values in the same
format as they are returned by
[localtime](https://perldoc.perl.org/functions/localtime). The
arguments are seconds, minutes, hours, day of month, month (January is
0 and December is 11), and year (in number of years since 1900; e.g.,
2000 would be passed in as 100). For example to find out how many
seconds will have passed at the start of the third millennium (*i.e.*,
Jan. 1, 2001) you can use code like this:

	use Time::Local;

	my $secs = timelocal(0, 0, 0, 1, 0, 101);

#### Examples: date and time manipulation using Perl built-in functions

With [localtime](https://perldoc.perl.org/functions/localtime) and
`timelocal` it is possible to do just about any kind of data
manipulation that you want. Here are a few simple examples.

##### Finding the date in x days time

This is, in principle, simple but there is one small complexity. The
method that we use is to find the current time (in seconds) using
localtime and add 86,400 (24 x 60 x 60) for each day that we want to
add. The complication arises when you try to calculate the date near
the time when daylight saving time either starts or finishes. At that
time you could have days of either 23 or 25 hours and this can affect
your calculation. To counter this we move the time to noon before
carrying out the calculation.

	use Time::Local;

	my @now = localtime;                 # Get the current date and time

	my @then = (0, 0, 12, @now[3 .. 5]); # Normalize time to 12 noon

	my $then = timelocal(@then);         # Convert to number of seconds

	$then += $x * 86_400;                # Where $x is the number of days to add

	@then = localtime($then);            # Convert back to array of values

	@then[0 .. 2] = @now[0 .. 2];        # Replace 12 noon with real time

	$then = timelocal(@then);            # Convert back to number of seconds

	print scalar localtime $then;        # Print result

##### Finding the date of the previous Saturday

Again, this is pretty simple, with just one slightly complex
calculation, which is explained in the comments. We work out the
current day of the week and, therefore, can work out the number of
days that we need to go back to get to Saturday.

	my @days = qw/Sunday Monday Tuesday Wednesday Thursday Friday
	              Saturday/;
	my @months = qw/January February March April May June July August
	                September October November December/;

	my $when = 6; # Saturday is day 6 in the week.
	              # You can change this line to get other days of the week.

	my $now = time;
	my @now = localtime($now);

	# This is the tricky bit.
	# $diff will be the number of days since last Saturday.
	# $when is the day of the week that we want.
	# $now[6] is the current day of the week.
	# We take the result modulus 7 to ensure that it stays in the
	# range 0 - 6.
	my $diff = ($now[6] - $when + 7) % 7;

	my $then = $now - (24 * 60 * 60 * $diff);

	my @then = localtime($then);

	$then[5] += 1900;

	print "$days[$then[6]] $then[3] $months[$then[4]] $then[5]";

##### Finding the date of the first Monday in a given year

This is very similar in concept to the last example. We calculate the
day of the week that January 1 fell on in the given year, and from
that we can calculate the number of days that we have to move forward
to get to the first Monday.

	use Time::Local;

	# Get the year to work on
	my $year = shift || (localtime)[5] + 1900;

	# Get epoch time of Jan 1st in that year
	my $jan_1 = timelocal(0, 0, 0, 1, 0, $year - 1900);

	# Get day of week for Jan 1
	my $day = (localtime($jan_1))[6];

	# Monday is day 1 (Sunday is day 0)
	my $monday = 1;

	# Calculate the number of days to the first Monday
	my $diff = (7 - $day + $monday) % 7;

	# Add the correct number of days to $jan_1
	print scalar localtime($jan_1 + (86_400 * $diff));

#### Better date and time formatting with POSIX::strftime

There is one other important date function that comes with the Perl
standard library. This is the `strftime` function that is part of the
[POSIX](http://metacpan.org/pod/POSIX) module. [POSIX](http://metacpan.org/pod/POSIX) is an attempt to standardize system calls across a
number of computer vendors’ systems (particularly among UNIX vendors)
and the Perl [POSIX](http://metacpan.org/pod/POSIX) module is an interface to these standard functions.
The strftime function allows you to format dates and times in a very
controllable manner. The function takes as arguments a format string
and a list of date and time values in the same format as they are
returned by [localtime](https://perldoc.perl.org/functions/localtime). The format string can contain any characters,
but certain character sequences will be replaced by various parts of
the date and time. The actual set of sequences supported will vary
from system to system, but most systems should support the sequences
shown in table 6.1.

|      |                              |
|------|------------------------------|
|	%a |  short day name (Sun to Sat) |
|	%A |  long day name (Sunday to Saturday) |
|	%b |  short month name (Jan to Dec) |
|	%B |  long month name (January to December) |
|	%c |  full date and time in the same format as localtime returns in scalar context |
|	%d |  day of the month (01 to 31) |
|	%H |  hour in 24-hour clock (00 to 23) |
|	%I |  hour in 12-hour clock (01 to 12) |
|	%j |  day of the year (001 to 366) |
|	%m |  month of the year (01 to 12) |
|	%M |  minutes after the hour (00 to 59) |
|	%p |  AM or PM |
|	%S |  seconds after the minute (00 to 59) |
|	%w |  day of the week (0 to 6) |
|	%y |  year of the century (00 to 99) |
|	%Y |  year (0000 to 9999) |
|	%Z |  time zone string (e.g., GMT) |
|	%% |  a percent character |

Table: POSIX::strftime character sequences

Here is a simple script which uses strftime.

	use POSIX qw(strftime);
	foreach ('%c', '%A %d %B %Y', 'Day %j', '%I:%M:%S%p (%Z)') {
	  print strftime($_, localtime), "\n";
	}

which gives the following output:

	 22/05/00 14:38:38
	 Monday 22 May 2000
	 Day 143
	 02:38:38PM (GMT Daylight Time)

#### International issues with date formats

One of the most intractable problems with dates has nothing to do with
computer software, but with culture. If I tell you that I am writing
this on 8/9/2000, without knowing whether I am European or American
you have no way of knowing if I mean the 8th of September or the 9th
of August. For that reason I’d recommend that whenever possible you
always use dates that are in the order year, month, and day as that is
far less likely to be misunderstood. There is an ISO standard (number
8601) which recommends that dates and times are displayed in formats
which can be reproduced using the `POSIX::strftime` templates
`%Y-%m-%dT%h:%M:%S` (for date and time) or `%Y-%m-%d` (for just the date).

All of the functions that we have just discussed come with every
distribution of Perl, so it's good to know that you can do useful date
manipulation with nothing but core Perl. But dealing directly with the
list of numbers returned by [localtime](https://perldoc.perl.org/functions/localtime) and reassembling them with
[Time::Local](http://metacpan.org/pod/Time::Local) gets tedious and
error-prone once a program needs to do much date arithmetic. Modern
Perl has two much better tools for this: [Time::Piece](http://metacpan.org/pod/Time::Piece),
a small module that has been part of the core Perl distribution since
Perl 5.10 (2007), and [DateTime](http://metacpan.org/pod/DateTime), a
much larger and more capable module from the CPAN. We will look at
both, using the same three example problems as before.

### Time::Piece

[Time::Piece](http://metacpan.org/pod/Time::Piece) replaces Perl's
built-in [localtime](https://perldoc.perl.org/functions/localtime)
function with a version that returns an object instead of a plain list
of numbers. That object gives you methods to do the fiddly parts of
date arithmetic—like adding days without having to worry about how
many seconds are in a day—without ever having to think about seconds
since the epoch yourself.

Because it ships with every Perl since 5.10, [Time::Piece](http://metacpan.org/pod/Time::Piece)
is a reasonable modern replacement for hand-rolled
[localtime](https://perldoc.perl.org/functions/localtime)/[Time::Local](http://metacpan.org/pod/Time::Local)
code even in situations where you can't install anything from the
CPAN.

#### Examples: date and time manipulation with Time::Piece

Let's revisit our three standard problems.

##### Finding the date in x days time

	use Time::Piece;
	use Time::Seconds;

	my $days = shift // 10;

	my $now = localtime;
	print $now + ($days * ONE_DAY);

Notice that [Time::Piece](http://metacpan.org/pod/Time::Piece) overrides
[localtime](https://perldoc.perl.org/functions/localtime) so that it
returns a Time::Piece object rather than the list of numbers we saw
earlier in the chapter. We can then just add seconds to that object—using
one of the constants exported by [Time::Seconds](http://metacpan.org/pod/Time::Piece)
(which is bundled with Time::Piece)—to get the date we want. Printing
the object directly gives a nicely formatted string; if you want a
different format, the object has a `strftime` method that works just
like the `POSIX::strftime` function we saw earlier.

##### Finding the date of the previous Saturday

	use Time::Piece;
	use Time::Seconds;

	my $now = localtime;
	my $days = $now->day_of_week + 1;
	print $now - ($days * ONE_DAY);

`day_of_week` returns a number between 0 and 6, with Sunday as 0—the
same convention used by the seventh element of the list returned by
[localtime](https://perldoc.perl.org/functions/localtime). Saturday is
therefore day 6, so we add one to the current day number to work out
how many days to go back.

##### Finding the date of the first Monday in a given year

	use Time::Piece;
	use Time::Seconds;

	my $year = shift // localtime->year;

	my $first_mon = Time::Piece->strptime("$year Jan 1", '%Y %b %e');

	$first_mon += (8 - $first_mon->day_of_week) % 7 * ONE_DAY;

	print $first_mon;

There's no constructor that lets you build a [Time::Piece](http://metacpan.org/pod/Time::Piece)
object for an arbitrary date directly, so instead we build one by
parsing a string with `strptime`—the inverse of `strftime`—and then
nudge it forward to the first Monday.

### DateTime

[DateTime](http://metacpan.org/pod/DateTime) is a much bigger module
than [Time::Piece](http://metacpan.org/pod/Time::Piece)—it isn't part
of the core Perl distribution, so it needs to be installed from the
CPAN—but it is also much more powerful. It sits at the centre of a
large ecosystem of related modules covering things like timezones,
non-Gregorian calendars, and flexible parsing of date strings in
unknown formats.

#### Examples: date and time manipulation with DateTime

Once more, let's look at our three standard problems.

##### Finding the date in x days time

	use DateTime;

	my $days = shift // 10;

	my $now = DateTime->now;
	print $now->add(days => $days);

The shape of this is very similar to the [Time::Piece](http://metacpan.org/pod/Time::Piece)
version. `DateTime->now` gives us an object holding the current date
and time, and `add` moves it forward by a number of days. Printing a
[DateTime](http://metacpan.org/pod/DateTime) object directly gives you
an ISO 8601 formatted string (the format recommended earlier in this
chapter); as with [Time::Piece](http://metacpan.org/pod/Time::Piece), a
`strftime` method is available if you want something else.

##### Finding the date of the previous Saturday

	use DateTime;

	my $now = DateTime->now;
	my $days = $now->day_of_week + 1;
	print $now->subtract(days => $days);

Again, this is essentially the same logic as the [Time::Piece](http://metacpan.org/pod/Time::Piece)
version, translated into DateTime's method calls.

##### Finding the date of the first Monday in a given year

	use DateTime;

	my $year = shift // DateTime->now->year;

	my $first_mon = DateTime->new(
	    year  => $year,
	    month => 1,
	    day   => 1,
	);

	my $days = (8 - $first_mon->day_of_week) % 7;

	print $first_mon->add(days => $days);

Unlike [Time::Piece](http://metacpan.org/pod/Time::Piece),
[DateTime](http://metacpan.org/pod/DateTime) has a real constructor, so
we can build an object for an arbitrary date directly instead of
parsing a string.

One important gotcha with `DateTime->now`: by default it works in the
UTC timezone, not your local timezone. That's fine as long as you're
consistent about it, but it's easy to get caught out—for example, a
script that runs date arithmetic around midnight local time can
quietly pick the wrong day if part of a calculation assumes UTC and
part assumes local time. If you want local time, ask for it
explicitly:

	my $now = DateTime->now(time_zone => 'local');

### Choosing between date modules

Both [Time::Piece](http://metacpan.org/pod/Time::Piece) and
[DateTime](http://metacpan.org/pod/DateTime) are a big improvement over
juggling raw lists of numbers from [localtime](https://perldoc.perl.org/functions/localtime),
so once you're past toy examples, reach for one of them rather than
hand-rolling the arithmetic yourself. Here are some of the advantages
that both bring over the built-in functions:

*  Your date and time lives in one structured object instead of several separate scalars.

*  Parsing date and time strings into an object is straightforward.

*  Producing different output formats is easy, via `strftime` (or DateTime's `format_cldr`, which gives you access to the full CLDR locale data rather than strftime's more limited set of formats).

*  Adding and subtracting dates and times is easy and doesn't require you to think about how many seconds are in a day.

*  The objects can be compared directly, so sorting a list of dates is simple.

*  You no longer need to remember that months run 0–11, or that the year is given as an offset from 1900.

So which should you use? [Time::Piece](http://metacpan.org/pod/Time::Piece)
has been in the Perl core since Perl 5.10, so it's a safe choice when
you can't install anything from the CPAN, and it's lightweight.
[DateTime](http://metacpan.org/pod/DateTime) has to be installed, and
it does more work internally to guarantee correctness—particularly
around timezones and calendar edge cases—so it's a heavier dependency,
but that thoroughness is exactly what you want once your problem gets
more complicated than these examples (recurring events, timezone
conversions, non-Gregorian calendars, and so on).

A reasonable rule of thumb: if [Time::Piece](http://metacpan.org/pod/Time::Piece)
can do the job, use it. Reach for [DateTime](http://metacpan.org/pod/DateTime)
(or one of the modules built on top of it) once you need the extra
power.

Extended example: web access logs
---------------------------------

One of the most common sources of line-oriented data is a web server
access log. It seems that everyone needs to wring as much information
as possible from these files in order to see if their web site is
attracting a large enough audience to justify the huge sums of money
spent on it.

Most web servers write access logs in a standard format. Here is a
sample of a real access log. This sample comes from a log written by
an Apache web server. Apache is the Open Source web server which runs
more web sites than any other server.

	158.152.136.193 - - [31/Dec/1999:21:27:27 -0800] "GET /index.html HTTP/1.1" 200 2987
	158.152.136.193 - - [31/Dec/1999:21:27:27 -0800] "GET /head.gif HTTP/1.1" 200 4389
	158.152.136.193 - - [31/Dec/1999:21:27:28 -0800] "GET /menu.gif HTTP/1.1" 200 7317

Each of these lines represents one access request that the server has
received. Let’s look at the fields in one of these lines and see what
each one represents.

The first field is the IP address from which the request came. It is
possible in most web servers to have these addresses resolved to
hostnames before they are logged, but on a heavily used site this can
seriously impact performance, so most webmasters leave this option
turned off.

The second and third fields (the two dash characters) denote which
user made this request. These fields will contain interesting data
only if the requested page is not public, so the user must go through
some kind of authorization in order to see it.

The fourth field is the date and time of the access. It shows the
local date and time together with the difference from UTC (so in this
case the server is hosted in the Pacific time zone of the U.S.A.).

The fifth field shows the actual HTTP request that was made. It is in
three parts: the request type (in this case, `GET`), the URL that was
requested, and the protocol used (HTTP/1.1).

The final two fields contain the response code that was returned to
the browser (`200` means that the request was successful and the
contents of the URL have been sent) and the number of bytes returned.

Armed with this knowledge we can look at the three lines and work out
exactly what happened. At half past nine on New Year’s Eve someone at
IP address `158.152.136.193` made three requests to the web site. The
person requested index.html, head.gif, and menu.gif. Each of these
requests was successful and we returned a total of 14,000 bytes to
them.

This kind of analysis is very useful and not very difficult, but a
busy web site will have many thousands of hits every day. How are you
supposed to get meaningful information from that amount of input
data? Using Perl, of course.

It wouldn’t be very difficult to write something to break apart a log
line and analyze the data, but it’s not completely simple—some fields
are separated by spaces, others have embedded spaces. Luckily this is
such a common task that someone has already written a module to
process web access logs. It is called [Logfile](http://metacpan.org/pod/Logfile) and you can find it on
the CPAN.

Using [Logfile](http://metacpan.org/pod/Logfile) is very simple. It consists of a number of submodules,
each tuned to handle a particular type of web server log. They are
all subclasses of the module [Logfile::Base](http://metacpan.org/pod/Logfile::Base). As our access log was
generated by Apache we will use [Logfile::Apache](http://metacpan.org/pod/Logfile::Apache).

[Logfile](http://metacpan.org/pod/Logfile) is an object-oriented module, so all processing is carried
out via a [Logfile](http://metacpan.org/pod/Logfile) object. The first thing we need to do is create a
[Logfile](http://metacpan.org/pod/Logfile) object.

	my $log = Logfile::Apache->new(File => 'access_log',
	                               Group => [qw(Host Date File Bytes User)]);

The named parameters to this function make it very easy to follow
what is going on. The `File` parameter is the name of the access log
that you want to analyze. `Group` is a reference to a list of indexes
that you will want to use to produce reports. The five indexes listed
in the code snippet correspond to sections of the Apache log record.
In addition to these, the module understands a couple of others.
`Domain` is the top level that the requesting host is in (e.g., .com,
.uk, .org), which is calculated from the hostname. Hour is the hour
of the day that the request took place. It is calculated from the
date field.

Having created the Logfile object you can then start to produce
reports with it. To list our files in order of popularity we can
simply do this:

	$log->report(Group => 'File');

which produces a report like this:

	File                       Records
	==================================
	/                        11  2.53%
	/examples                 1  0.23%
	/examples/index.html      1  0.23%
	/images/graph             1  0.23%
	/images/pix               1  0.23%
	/images/sidebar           1  0.23%
	/images/thumbnail         5  1.15%
	/index                    1  0.23%
	.
	.
	.
	[other lines snipped]

This is an alphabetized list of all of the files that were listed in
the access log. We can make more sense if we sort the output by
number of hits and perhaps just list the top ten files by changing
the code like this:

	$log->report(Group => 'File', Sort => 'Records', Top => 10);

We then get a more understandable report that looks like this:

	File                       Records
	==================================
	/new/images             129 29.72%
	/new/music               80 18.43%
	/new/personal            52 11.98%
	/new/friends             47 10.83%
	/splash/splashes         28  6.45%
	/new/pics                26  5.99%
	/new/stuff               21  4.84%
	/                        11  2.53%
	/new/splash               6  1.38%
	/images/thumbnail         5  1.15%

Perhaps instead of wanting to know the most popular files, you are
interested in the most popular times of the day that people visit
your site. You can do this using the Hour index. The following:

	$log->report(Group => 'Hour');

will list all of the hours in chronological order and

	$log->report(Group => 'Hour', Sort => 'Records');

will order them by the number of hits in each hour. If you want to
find the quietest time of the day, simply reverse the order of the
sort

	$log->report(Group => 'Hour', Sort => 'Records', Reverse => 1);

There are a number of other types of reports that you can get using
`Logfile`, but it would be impossible to cover them all here. Have a
look at the examples in the *README* file and the test files to get
some good ideas.

Further information
-------------------

For more information about the `$/`, `$,`, and `$"` variables (together with
other useful Perl variables) see the `perldoc perlvar` manual pages.

For more information about the built-in date handling functions see
the `perldoc perlfunc` manual pages.

For more information about the `POSIX::strftime` function see the
`perldoc POSIX` manual page and your system’s documentation for a list
of supported character sequences.

[Time::Piece](http://metacpan.org/pod/Time::Piece) ships with every
modern Perl, so `perldoc Time::Piece` will always work.
[DateTime](http://metacpan.org/pod/DateTime) is available from the
CPAN; once installed, `perldoc DateTime` gives you its full
documentation, and [metacpan.org](https://metacpan.org/pod/DateTime)
is a good place to browse the wider DateTime ecosystem of related
modules.

Summary
-------

*  Record-oriented data is very easy to handle in Perl, particularly if you make appropriate use of the I/O control variables such as `$/`, `$"`, and `$,`.

*  The [Text::CSV_XS](http://metacpan.org/pod/Text::CSV_XS) CPAN module makes it very easy to read and write comma-separated values.

*  Data caching can speed up your programs when used carefully, and using Memoize.pm can make adding caching to a program very easy.

*  Perl has very powerful built-in date and time processing functions.

*  [Time::Piece](http://metacpan.org/pod/Time::Piece) (core) and [DateTime](http://metacpan.org/pod/DateTime) (CPAN) make date and time arithmetic far less error-prone than working directly with the values returned by `localtime`.
