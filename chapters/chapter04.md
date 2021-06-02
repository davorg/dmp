Chapter 4: Pattern matching
=============================

What this chapter covers:

*  String handling functions

*  Functions for case transformation

*  Regular expressions—what they are and how to use them

*  Taking regular expressions to extremes

A lot of data munging involves the use of pattern matching. In fact,
it’s probably fair to say that the vast majority of data munging uses
pattern matching in one way or another. Most pattern matching in Perl
is carried out using regular expressions. It is
therefore very important that you understand how to use them. In this
chapter we take an overview of regular expressions in Perl and how
they can be used in data munging, but we start with a brief look at a
couple of methods for pattern matching that don’t involve regular
expressions.

String handling functions
----------

Perl has a number of functions for handling strings and these are
often far simpler to use and more efficient than the regular
expression-based methods that we will discuss later. When considering
how to solve a particular problem, it is always worth seeing if you
can use a simpler method before going straight for a solution using
regular expressions.

### Substrings

If you want to extract a particular portion of a string then you can
use the substr function. This function takes two mandatory
parameters: a string to work on and the offset to start at, and two
optional parameters: the length of the required substring and another
string to replace it with. If the third parameter is omitted, then
the substring will include all characters in the source string from
the given offset to the end. The offset of the first character in
the source string is 0. If the offset is negative then it counts
from the end of the string. Here are a few simple examples:

	my $string = 'Alas poor Yorick. I knew him Horatio.';
	my $sub1 = substr($string, 0, 4);    # $sub1 contains 'Alas'
	my $sub2 = substr($string, 10, 6);   # $sub2 contains 'Yorick'
	my $sub3 = substr($string, 29);      # $sub3 contains 'Horatio.'
	my $sub4 = substr($string, -12, 3);  # $sub4 contains 'him'

Many programming languages have a function that produces substrings in
a similar manner, but the clever thing about Perl’s substr function is
that the result of the operation can act as an lvalue. That is, you
can assign values to it, like this:

	my $string = 'Alas poor Yorick. I knew him Horatio.';
	substr($string, 10, 6) = 'Robert';
	substr($string, 29) = 'as Bob';
	print $string;

which will produce the output:

	Alas poor Robert. I knew him as Bob

Notice the second assignment in this example which demonstrates that
the substring and the text that you are replacing it with do not
have to be the same length. Perl will take care of any necessary
manipulation of the strings. You can even do something like this:

	my $short = 'Short string';
	my $long = 'Very, very, very, very long';
	substr($short, 0, 5) = $long;

which will leave \$short containing the text “Very, very, very, very
long string”.

### Finding strings within strings (index and rindex)

Two more functions that are useful for this kind of text manipulation
are index and rindex. These functions do very similar things—index
finds the first occurrence of a string in another string and rindex
finds the last occurrence. Both functions return an integer indicating
the position in the source string where the given substring begins,
and both take an optional third parameter which is the position where
the search should start. Here are some simple examples:

	my $string = 'To be or not to be.';
	my $pos1 = index($string, 'be');
	# $pos1 is 3
	my $pos2 = rindex($string, 'be');
	# $pos2 is 16
	my $pos3 = index($string, 'be', 5);
	# $pos3 is 16
	my $pos4 = index($string, 'not');
	# $pos4 is 9
	my $pos5 = rindex($string, 'not');
	# $pos5 is 9

It’s worth noting that `$pos3` is 16 because we don’t start looking
until position 5; and `$pos4` and `$pos5` are equal because there is
only one instance of the string 'not' in our source string.

It is, of course, possible to use these three functions in
combination to carry out more complex tasks. For example, if you had
a string and wanted to extract the middle portion that was contained
between square brackets (`[` and `]`), you could do something like this:

	my $string = 'Text with an [important bit] in brackets';
	my $start = index($string, '[');
	my $end = rindex($string, ']');
	my $keep = substr($string, $start+1, $end-$start-1);

although in this case, the regular expression solution would probably
be more easily understood.

### Case transformations

Another common requirement is to alter the case of a text string,
either to change the string to all upper case, all lower case, or
some combination. Perl has functions to handle all of these
eventualities. The functions are [uc](https://perldoc.perl.org/functions/uc) (to convert a whole string to
upper case), [ucfirst](https://perldoc.perl.org/functions/ucfirst) (to convert the first character of a string to
upper case), [lc](https://perldoc.perl.org/functions/lc) (to convert a whole string to lower case), and
[lcfirst](https://perldoc.perl.org/functions/lcfirst) (to convert the first character of a string to lower case).

There are a couple of traps that seem to catch unwary programmers who
use these functions. The first of these is with the ucfirst and
lcfirst functions. It is important to note that they do exactly what
they say and affect only the first character in the given string. I
have seen code like this:

	$string = ucfirst 'UPPER';
	# This doesn’t work

where the programmer expects to end up with the string 'Upper'. The
correct code to achieve this is:

	$string = ucfirst lc 'UPPER';

The second trap for the unwary is that these functions will respect
your local language character set, but to make use of that, you need
to switch on Perl’s locale support by including the line use locale
in your program.

Regular expressions
----------

In this section we take a closer look at regular expressions. This is
one of Perl’s most powerful tools for data munging, but it is also a
feature that many people have difficulty understanding.

### What are regular expressions?

“Regular expression” is a very formal computer science sounding term
for something that would probably scare people a great deal less if
we simply called it “pattern matching,” because that is basically
what we are talking about.

If you have some data and you want to know whether or not certain
strings are present within the data set, then you need to construct a
regular expression that describes the data that you are looking for
and see whether it matches your data. Exactly how you construct the
regular expression and match it against your data will be covered
later in the chapter. First we will look at the kinds of things that
you can match with regular expressions.

Many text-processing tools support regular expressions. UNIX tools
like vi, sed, grep, and awk all support them to varying degrees. Even
some Windows-based tools like Microsoft Word allow you to search text
using basic kinds of regular expressions. Of all of these tools, Perl
has the most powerful regular expression support.

Among others, Perl regular expressions can match the following:

*  A text phrase

*  Phrases containing optional sections

*  Phrases containing repeated sections

*  Alternate phrases (*i.e.*, either *this* or *that*)

*  Phrases that must appear at the start or end of a word

*  Phrases that must appear at the start or end of a line

*  Phrases that must appear at the start or end of the data

*  Any character from a group of characters

*  Any character not from a group of characters

Recent versions of Perl have added a number of extensions to the
standard regular expression set, some of which are still
experimental at the time of this writing. For the definitive,
up-to-date regular expression documentation for your version of Perl
see the perlre documentation page.

### Regular expression syntax

In Perl you can turn a string of characters into a regular expression
by enclosing it in slash characters (`/`). So, for example

	/regular expression/

is a regular expression which matches the string “regular expression”.

#### Regular expression metacharacters

Within a regular expression most characters will match themselves
unless their meaning is modified by the presence of various
metacharacters. The list of meta-characters that can be used in Perl
regular expressions is

	\ | ( ) [ { ^ $ * + ? .

Any of these metacharacters can be used to match itself in a regular
expression by preceding it with a backslash character (`\`). You’ll
see that the backslash is itself a metacharacter, so to match a
literal backslash you’ll need to have two backslashes in your regular
expression `/foo\\bar/` matches `foo\bar`.

The dot character (`.`) matches any character.

The normal escape sequences that are familiar from many programming
languages are also available. A tab character is matched by `\t`, a
newline by `\n`, a carriage return by `\r`, and a form feed by `\f`.

#### Character classes

You can match any character in a group of characters (known in Perl as
a *character class*) by enclosing the list of characters within square
brackets (`[` and `]`). If a group of characters are consecutive in your
character set, then you can use a dash character (`-`) to denote a range
of characters. Therefore the regular expression

	/[aeiouAEIOU]/

will match any vowel and

	/[a-z]/

will match any lower case letter.

To match any character that is not in a character class, put a caret
(`^`) at the start of the group, so

	/[\^aeiouAEIOU]/

matches any nonvowel (note that this does not just match consonants;
it will also match punctuation characters, spaces, control
characters—and even extended ASCII characters like ñ, «, and é).

#### Escape sequences

There are a number of predefined character classes that can be denoted
using escape sequences. Any digit is matched by `\d`. Any word
character (*i.e.*, digits, upper and lower case letters, and the
underscore character) is matched by `\w` and any white space character
(space, tab, carriage return, line feed, or form feed) is matched by
`\s`. The inverses of these classes are also defined. Any nondigit is
matched by `\D`, any nonword character is matched by `\W`, and any
nonspace character is matched by `\S`.

#### Matching alternatives

The vertical bar character (`|`) is used to denote alternate matches. A
regular expression, such as:

	/regular expression|regex/

will match either the string “regular expression” or the string
“regex”. Parentheses (`(` and `)`) can be used to group strings, so while

	/regexes are cool|rubbish/

will match the strings “regexes are cool” or “rubbish”,

	/regexes are (cool|rubbish)/

will match “regexes are cool” or “regexes are rubbish”.

#### Capturing parts of matches

A side effect of grouping characters using parentheses is that if a
string matches a regular expression, then the parts of the string
which match the sections in parentheses will be stored in special
variables called `$1`, `$2`, `$3`, etc. For example, after matching a
string against the previous regular expression, then `$1` will contain
the string “cool” or “rubbish.” We will see more examples of this
later in the chapter.

#### Quantifying matches

You can also quantify the number of times that a string should appear
using the `+`, `*`, or `?` characters. Putting `+` after a character (or
string of characters in a parentheses or a character class) allows
that item to appear one or more times, `*` allows the item to appear
zero or more times, and `?` allows the item to appear zero or one time
(*i.e.*, it becomes optional). For example:

	/so+n/

will match “son”, “soon”, or “sooon”, etc., whereas

	/so*n/

will match “sn”, “son”, “soon”, and “sooon”, etc., and

	/so?n/

will only match “sn”, and “son”.

Similarly for groups of characters,

	/(so)+n/

will match “son”, “soson”, or “sososon”, etc., whereas

	/(so)*n/

will match “n”, “son”, “soson”, and “sososon”, etc., and

	/(so)?n/

will match only “n” and “son”.

You can have more control over the number of times that a term
appears using the `{n,m}` syntax. In this syntax the term to be
repeated is followed by braces containing up to two numbers separated
by a comma. The numbers indicate the minimum and maximum times that
the term can appear. For example, in the regular expression

	/so{1,2}n/

the “o” will match if it appears once or twice, so “son” or “soon”
will match, but “sooon” will not. If the first number is omitted,
then it is assumed to be zero and if the second number is omitted
then there is assumed to be no limit to the number of occurrences
that will match. You should notice that the `+`, `*`, and `?` forms that
we used earlier are not strictly necessary as they could be indicated
using `{1,}`, `{0,}`, and `{0,1}`. If only one number appears without a
comma then the expression will match if the term appears exactly that
number of times.

#### Anchoring matches

It is also possible to anchor parts of your regular expression at
various points of the data. If you want to match a regular expression
only at the start of your data you can use a caret (`^`). Similarly, a
dollar sign (`$`) matches at the end of the data. To match an email
header line which consists of a string such as “From”, “To”, or
“Subject” followed by a colon, an optional space and some more text,
you could use a regular expression like this:

	/\^[\^:]+: ?.+\$/

which matches the start of the line followed by at least one noncolon
character, followed by a colon, an optional space, and at least one
other character before the end of the line.

You could also write this as `/^.+?: ?.+$/`, but we don’t cover the
syntax for nongreedy matching until later in the chapter.

Other special terms can be used to match at word boundaries. The term
`\b` matches only at the start or end of a word (*i.e.*, between a `\w`
character and a `\W` character) and its inverse `\B` only matches
within a word (*i.e.*, between two `\w` characters). For instance, if
we wanted to match “son”, but didn’t want to match it at the end of
names like “Johnson” and “Robertson” we could use a regular
expression like:

	/\bson\b/

and if we were only interested in occurrences of “son” at the end of
other words, we could use:

	/\Bson\b/

#### More complex regular expressions

Recent versions of Perl have added more complexity to regular
expressions allowing you to define more complex rules against which
you match your strings. The full explanation of these enhancements is
in your Perl documentation, but the most important additions are:

* `(?: … )`—These parentheses group in the same way that normal brackets do, but when they match, their contents don’t get assigned to `$1`, `$2`, etc.

* `(?= … )`—This is known as positive lookahead. It enables you to check that whatever is between the parentheses exists there in the string, but it doesn’t actually consume the next part of the string that is being matched.

* `(?! … )`—This is negative lookahead, which is the opposite of positive lookahead. You will only get a match if whatever is in the parentheses does not match the string there.

### Using regular expressions

Most regular expressions are used in Perl programs in one of two
ways. The simpler way is to check if a data string matches the
regular expression, and the slightly more complex way is to replace
parts of data strings with other strings.

#### String matching

To match a string against a regular expression in Perl we use the
match operator—which is normally called `m//`, although it is quite
possible that it looks nothing like that when you use it.

By default, the match operator works on the `$_` variable. This works
very well when you are looping through an array of values. Imagine,
for example, that you have a text file containing email messages and
you want to print out all of the lines containing “From” headers. You
could do something like this:

	open MAIL, 'mail.txt' or die "Can’t open mail.txt: \$!";
	while (\<MAIL\>) {
	print if m/\^From:/;
	}

The while loop reads in another line from the file each time around
and stores the line in `$_`. The match operator checks for lines
beginning with the string “From:” (note the `^` character that matches
the start of the line) and returns true for lines that match. These
lines are then printed to `STDOUT`.

One nice touch with the match operator is that in many cases the m is
optional so we can write the match statement in our scripts as

	print if /\^From:/;

and that is how you will see it in most scripts that you encounter.
It is also possible to use delimiters other than the `/` character, but
in this case the m becomes mandatory. To see why you might want to
do this, look at this example:

	open FILES 'files.txt' or die "Can't open files.txt: \$!";
	while (\<FILES\>) {
	print if /\\/davec\\//;
	}

In this script we are doing a very similar thing to the previous
example, but in this case we are scanning a list of files and
printing the ones that are under a directory called `davec`. The
directory separator character is also a slash, so we need to escape
it within the regular expression with backslashes and the whole
thing ends up looking a little inelegant (this is sometimes known
as "leaning toothpick syndrome"). To get around this, Perl allows us to
choose our own regular expression delimiter. This can be any
punctuation character, but if we choose one of the paired delimiter
characters (`(`, `{`, `[` or `<`) to open our regular expression we must
use the opposite character (`)`, `}`, `]` or `>`) to close it, otherwise
we just use the same character. We can therefore rewrite our match
line as

	print if m(/davec/);

or

	print if m|/davec/|;

or even

	print if m=/davec/=;

any of which may well be easier to read than the original. Note that
in all of these cases we have to use the m at the start of the
expression.

#### More capturing

Once a match has been successful, Perl sets a number of special
variables. For each bracketed group in your regular expression, Perl
sets a variable. The first bracket group goes into `$1`, the second
into `$2`, and so on. Bracketed groups can be nested, so the order of
assignment to these variables depends upon the order of the opening
bracket of the group. Going back to our earlier email header example,
if we had an email in a text file and wanted to print out all of the
headers, we could do something like this (conveniently ignoring the
fact that email headers can continue onto more than one  line and that
an email body can contain the character “:”):

	open MAIL, 'mail.txt' or die "Can't open mail.txt: $!";
	while (<MAIL>) {
	  if (/^([^:]+): ?(.+)$/) {
	    print "Header \$1 has the value \$2\\n";
	  }
	}

We have added two sets of brackets to the original regular expression
which will capture the header name and value into `$1` and `$2` so that
we can print them out in the next line. If a match operation is
evaluated in an array context, it returns the values of `$1`, `$2`, and
so forth in a list. We could, therefore, rewrite the previous example
as:

	open MAIL, 'mail.txt' or die "Can't open mail.txt: \$!";
	my ($header, $value);
	while (<MAIL>) {
	  if (($header, $value) = /^([^:]+): ?(.+)$/) {
	    print "Header $header has the value $value\n";
	  }
	}

There are other variables that Perl sets on a successful match. These
include `$&` which is set to the part of the string that matched the
whole regular expression, `` $` `` which is set to the part of the string
before the part that matched the regular expression, and `$'` which is
set to the part of the string after the part that matched the regular
expressions. Therefore after executing the following code:

	$_ = 'Matching regular expressions';
	m/regular expression/;

`$&` will contain the string “regular expression”, `` $` `` will contain
“Matching ”, and `$'` will contain “s”. Obviously these variables are
far more useful if your regular expression is not a fixed string.

There is one small downside to using these variables. Perl has to do
a lot more work to keep them up to date. If you don’t use them it
doesn’t set them. However, if you use them in just one match in your
program, Perl will then keep them updated for every match. Using them
can therefore have an effect on performance.

#### Matching against other variables

Obviously not every string that you are going to want to match is
going to be in `$_`, so Perl provides a binding operator which binds
the match to another variable. The operator looks like this:

	$string =~ m/regular expression/

This statement searches for a match for the string “regular
expression” within the text in the variable `$string`.

#### Match modifiers

There are a number of optional modifiers that can be applied to the
match operator to change the way that it works. These modifiers are
all placed after the closing delimiter. The most commonly used
modifier is `i` which forces the match to be case-insensitive, so that

	m/hello/i

will match “hello”, “HELLO”, “Hello”, or any other combination of
cases. Earlier we saw a regular expression for matching vowels that
looked like this

	/[aeiouAEIOU]/

Now that we have the `i` modifier, we can rewrite this as

	/[aeiou]/i

The next two modifiers are `s` and `m` which force the match to treat the
data string as either single or multiple lines. In multiple line
mode, `.` will match a newline character (which would not happen by
default). Also `^` and `$` will match at the start and end of any line.
To match the start and end of the entire string you can use the
anchors `\A` and `\Z`.

The final modifier is `x`. This allows you to put white space and
comments within your regular expressions. The regular expressions
that we have looked at so far have been very simple, but regular
expressions are largely what give Perl its reputation of being
written in line noise. If we look again at the regular expression we
used to match email headers, is it easier to follow like this:

	m/^[^:]+\s?.+$/

 or like this

	m/^
	      # start of line
	[^:]+ # at least one non-colon
	:     # a colon
	\\s?  # an optional white space character
	.+    # at least one other character
	$/x   # end of line

And that’s just a simple example!

#### String replacement

The string replacement operation looks strikingly similar to the
string-matching operator, and works in a quite similar fashion. The
operator is usually called `s///` although, like the string-matching
operator, it can actually take many forms.

The simplest way of using the string replacement operator is to
replace occurrences of one string with another string. For example
to replace “Dave” with “David” you would use this code:

	s/Dave/David/

The first expression (Dave) is evaluated as a regular expression. The
second expression is a string that will replace whatever matched
the regular expression in the original data string. This
replacement string can contain any of the variables that get set on a
successful match. It is therefore possible to rewrite the previous
example as:

	s/(Dav)e/${1}id/

As with the match operator, the operation defaults to affecting
whatever is in the variable `$_`, but you can bind the operation to
a different variable using the `=~` operator.

#### Substitution modifiers

All of the match operator modifiers (`i`, `s`, `m`, and `x`) work in the same
way on the substitution operator but there are a few extra modifiers.
By default, the substitution only takes place on the first string
matched in the data string. For example:

	my $data = "This is Dave’s data. It is the data belonging to Dave";
	$data =~ s/Dave/David/;

will result in `$data` containing the string “This is David’s data. It
is the data belonging to Dave”. The second occurrence of Dave was
untouched. In order to affect all occurrences of the string we can
use the g modifier.

	my $data = "This is Dave’s data. It is the data belonging to Dave";
	$data =~ s/Dave/David/g;

This works as expected and leaves `$data` containing the string “This
is David’s data. It is the data belonging to David”.

The other two new modifiers only affect the substitution if either
the search string or the replacement string contains variables or
executable code. Consider the following code:

	my ($new, $old) = @ARGV;
	while (<STDIN>) {
	  s/$old/$new/g;
	  print;
	}

which is a very simple text substitution filter. It takes two strings
as arguments. The first is a string to search for and the second is a
string to replace it with. It then reads whatever is passed to it on
`STDIN` and replaces one string with the other. This certainly works,
but it is not very efficient. Each time around, the loop Perl doesn’t
know that the contents of `$old` haven’t changed so it is forced to
recompile the regular expression each time. We, however, know that
`$old` has a fixed value. We can therefore let Perl know this, by
adding the o modifier to the substitution operator. This tells Perl
that it is safe to compile the regular expression once and to reuse
the same version each time around the loop. We should change the
substitution line to read

	s/$old/$new/go;

There is one more modifier to explain and that is the e modifier. When
this modifier is used, the replacement string is treated as executable
code and is passed to eval. The return value from the evaluation is
then used as the replacement string. As an example, here is a fairly
strange way to print out a table of squares:

	foreach (1 .. 12) {
	  s/(\d+)/print "$1 squared is ", $1*$1, "\n"/e;
	}

 which produces the following output:

	 1 squared is 1
	 2 squared is 4
	 3 squared is 9
	 4 squared is 16
	 5 squared is 25
	 6 squared is 36
	 7 squared is 49
	 8 squared is 64
	 9 squared is 81
	 10 squared is 100
	 11 squared is 121
	 12 squared is 144

### Example: translating from English to American

To finish this overview of regular expressions, let’s write a script
that translates from English to American. To make it easier for
ourselves we’ll make a few assumptions.

We’ll assume that each English word has just one American translation.
We’ll also store our translations in a text file so it is easy to add
to them. The program will look something like this:

	  1: #!/usr/bin/perl -w
	  2: use strict;
	  3:
	  4: while (<STDIN>) {
	  5:
	  6:   s/(\w+)/translate($1)/ge;
	  7:   print;
	  8: }
	  9:
	 10: my %trans;
	 11: sub translate {
	 12:   my $word = shift;
	 13:
	 14:   $trans{lc $word} ||= get_trans(lc $word);
	 15: }
	 16:
	 17: sub get_trans {
	 18:   my $word = shift;
	 19:
	 20:   my $file = 'american.txt';
	 21:   open(TRANS, $file) || die "Can't open $file: $!";
	 22:
	 23:   my ($line, $english, $american);
	 24:   while (defined($line = <TRANS>)) {
	 25:     chomp $line;
	 26:     ($english, $american) = split(/\t/, $line);
	 27:     do {$word = $american; last; } if $english eq $word;
	 28:   }
	 29:   close TRANS;
	 30:   return $word;
	 31: }

#### How the translation program works

Lines 1 and 2 are the standard way to start a Perl script.

The loop starting on line 4 reads from `STDIN` and puts each line in
turn in the `$_` variable.

Line 6 does most of the work. It looks for groups of word characters.
Each time it finds one it stores the word in `$1`. The replacement
string is the result of executing the code translate(`$1`). Notice
the two modifiers: `g` which means that every word in the line will be
converted, and `e` which forces Perl to execute the replacement string
before putting it back into the original string.

Line 7 prints the value of `$_`, which is now the translated line.
Note that when given no arguments, print defaults to printing the
contents of the `$_` variable—which in this case is exactly what we
want.

Line 10 defines a caching hash which the translate function uses to
store words which it already knows how to translate.

The translate function which starts on line 11 uses a caching
algorithm similar to the Orcish Manoeuvre. If the current word doesn’t
exist in the `%trans` hash, it calls `get_trans` to get a translation
of the word. Notice that we always work with lower case versions of
the word.

Line 17 starts the `get_trans` function, which will read any necessary
words from the file containing a list of translatable words.

Line 20 defines the name of the translations file and line 21
attempts to open it. If the file can’t be opened, then the program
dies with an error message.

Line 24 loops though the translations file a line at a time, putting
each line of text into `$line` and line 25 removes the newline
character from the line.

Line 26 splits the line on the tab character which separates the
English and American words.

Line 27 sets `$word` to the American word if the English word matches
the word we are seeking.

Line 29 closes the file.

Line 30 returns either the translation or the original word if a
translation is not found while looping through the file. This ensures
that the function always returns a valid word and therefore that the
`%trans` hash will contain an entry for every word that we’ve come
across. If we didn’t do this, then for each word that didn’t need to
be translated, we would have no entry in the hash and would have to
search the entire translations file each time. This way we only search
the translations file once for each unique word.

#### Using the translation program

As an example of the use of this script, create a file called
`american.txt` which contains a line for each word that you want to
translate. Each line should have the English word followed by a tab
character and the equivalent American word. For example:

	hello\<TAB\>hiya
	pavement\<TAB\>sidewalk

Create another file containing the text that you want to translate.
In my test, I used

	Hello.
	Please stay on the pavement.

and running the program using the command line

	translate.pl \< in.txt

produced the output

	hiya.
	Please stay on the sidewalk.

If you wanted to keep the translated text in another text file then
you could run the program using the command line

	translate.pl \< in.txt \> out.txt

Once again we make use of the power of the UNIX filter model as
discussed in [Chapter 2](ch005.xhtml).

This isn’t a particularly useful script. It doesn’t, for example,
handle capitalization of the words that it translates. In the next
section we’ll look at something a little more powerful.

### More examples: /etc/passwd

Let’s look at a few more examples of real-world data munging tasks for
which you would use regular expressions. In these examples we will use
a well-known standard UNIX data file as our input data. The file we
will use is the `/etc/passwd` file which stores a list of users on a
UNIX system. The file is a colon-separated, record-based file. This
means that each line in the file represents one user, and the various
pieces of information about each user are separated with a colon. A
typical line in one of these files looks like this:

	dave:Rg6kuZvwIDF.A:501:100:Dave Cross:/home/dave:/bin/bash

The seven sections of this line have the following meanings:

	 1 The username
	 2 The user’s password (in an encrypted form)9
	 3 The unique ID of the user on this system
	 4 The ID of the user’s default group
	 5 The user’s full name10
	 6 The path to the user’s home directory
	 7 The user’s command shell
	 9 On a system using shadow passwords, the encrypted password won’t be in this field.
	10 Strictly, this field can contain any text that the system administrator chooses—but this is my system and

I’ve chosen to store full names here.

The precise meaning of some of these fields may not be clear to
non-UNIX users, but it should be clear enough to understand the
following examples.

#### Example: reading /etc/passwd

Let’s start by writing a routine to read the data into internal data
structures. This routine can then be used by any of the following
examples. As always, for flexibility, we’ll assume that the data is
coming in via `STDIN`.

	sub read_passwd {
	  my %users;
	  my @fields = qw/name pword uid gid fullname home shell/;
	  while (<STDIN>) {
	    chomp;
	    my %rec;
	    @rec{@fields) = split(/:/);
	      $users{$rec->{name}} = \%rec;
	  }
	  return \%users;
	}

In a similar manner to other input routines we have written, this
routine reads the data into a data structure and returns a reference
to that data structure. In this case we have chosen a hash as the
main data structure, as the users on the system have no implicit
ordering and it seems quite likely that we will want to get the
information on a specific user. A hash allows us to do this very
easily. This raises one other issue: what is the best choice for the
key of the hash? The answer depends on just what we are planning to
do with the data, but in this case I have chosen the username. In
other cases the user ID might be a useful choice. All of the other
columns would be bad choices, as they aren’t guaranteed to be unique
across all users.

So, we have decided on a hash where the keys are the usernames. What
will the values of our hash be? In this case I have chosen to use
another level of hash where the keys are the names of the various
data values (as defined in the array `@fields`) and the values are the
actual values.

Our input routine therefore reads each line from `STDIN` and splits it
on colons and puts the values directly into a hash called `%rec`. A
reference to `%rec` is then stored in the main `%users` hash. Notice that
because `%rec` is a lexical variable that is scoped to within the while
loop, each time around the loop we get a new variable and therefore a
new reference. If `%rec` were declared outside the loop it would always
be the same variable and every time around the loop we would be
overwriting the same location in memory.

Having created a hash for each line in the input file and assigned it
to the correct record in `%users`, our routine finally returns a
reference to `%users`. We are now ready to start doing some real work.

#### Example: listing users

To start with, let’s produce a list of all of the real names of all of
the users on the system. As that would be a little too simple we’ll
introduce a couple of refinements. First, included in the list of
users in `/etc/passwd` are a number of special accounts that aren’t for
real users. These will include root (the superuser), lp (a user ID
which is often used to carry out printer administration tasks) and a
number of other task-oriented users. Assuming that we can detect these
uses by the fact that their full names will be empty, we’ll exclude
them from the output. Secondly, in the original file, the full names
are in the format `<forename> <surname>`. We’ll print them out as
`<surname>, <forename>`, and sort them in surname order. Here’s the
script:

	  1: use strict;
	  2:
	  3: my $users = read_passwd();
	  4:
	  5: my @names;
	  6: foreach (keys %{$users}) {
	  7:   next unless $users->{$_}{fullname};
	  8:
	  9:   my ($forename, $surname) = split(/\s+/, $users->{$_}{fullname}, 2);
	 10:
	 11:   push @names, "$surname, $forename";
	 12: }
	 13:
	 14: print map { "$_\n" } sort @names;

Most of this script is self-explanatory. The key lines are:

Line 6 gets each key in the `%users` hash in turn.

Line 7 skips any record that doesn’t have a full name, thereby
ignoring the special users.

Line 9 splits the full name on white space. Note that we pass a third
argument to `split`, assuming that the first word in the name is the
forename and everything else is the surname. This limits the number of
elements in the returned list.

Line 11 builds the reversed name and pushes it onto another array.

Line 14 prints the array of names in sorted order.

#### Example: listing particular users

Now suppose we want to get a report on the users that use the Bourne
shell (*/bin/sh*). Maybe we want to email them to suggest that they use
bash instead. We might write something like this:

	1: use strict;
	2:
	3: my $users = read_passwd();
	4:
	6: foreach (keys %{$users}) {
	7:
	print "$_\n" if $users->{$_}{shell} eq '/bin/sh';
	8: }

Again we have a very simple script. Most of the real work is being
done on line 7. This line checks the value in `$users->{$_}{shell}`
against the string “/bin/sh”, and if it matches it prints out the
current key (which is the username). Notice that we could also have
chosen to match against a regular expression using the code

	print "$_\n" if $users->{$_}{shell} =~ m|^/bin/sh$|

If performance is important to you, then you could benchmark the two
solutions and choose the faster one. Otherwise the solution you
choose is a matter of personal preference.

### Taking it to extremes

Of course, using regular expressions for transforming data is a very
powerful technique and, like all powerful techniques, it is open to
abuse. As an example of what you can do with this technique, let’s
take a brief look at the [Text::Bastardize](http://metacpan.org/pod/Text::Bastardize) module which is available
from the CPAN at [http://metacpan.org/pod/Text::Bastardize](http://metacpan.org/pod/Text::Bastardize).

This module will take an innocent piece of text and will abuse it in
various increasingly bizarre ways. The complete set of
transformations available in the current version (0.08 as of the
time of writing) is as follows:

*  *rdct*—Converts the text to hyperreductionist English. This removes vowels within words, changes “you” to “u” and “are” to “r” and carries out a number of other conversions.

*  *pig*—Converts the text to Pig Latin. Pig Latin is a bizarre corruption of English in which the first syllable of a word is moved to the end of the word and the sound “ay” is appended.

*  *k3wlt0k*—Converts the text to “cool-talk” as used by certain denizens of the Internet (“the d00dz who deal in k3wl war3z”).

*  *rot13*—Applies rot13 “encryption” to the text. In this very basic type of encryption, each letter is replaced with one that is thirteen letters past it in the alphabet. This method is often used in newsgroup posts to disguise potential plot spoilers or material which might give offense to casual readers.

*  *rev*—Reverses the order of the letters in the text.

*  *censor*—Censors text which might be thought inappropriate. It does this by replacing some of the vowels with asterisks.

*  *n20e*—Performs numerical abbreviations on the text. Words over six letters in length have all but their first and last letters removed and replaced with a number indicating the number of letters removed.

It is, of course, unlikely that this module is ever used as anything
other than an example of a text transformation tool, but it is a very
good example of one and it can be very instructive to look at the
code of the module. As an example of the use of the module, here is
a script that performs all of the transformations in turn on a piece
of text that is read from `STDIN`. Notice that the piece of text that
is to be transformed is set using the charge function.

	#!/usr/perl/bin/perl -w
	use strict;
	use Text::Bastardize;
	my $text = Text::Bastardize->new;
	print 'Say something: ';
	while (<STDIN>) {
	  chomp;
	  $text->charge($_);
	  foreach my $xfm (qw/rdct pig k3wlt0k rot13 rev censor n20e/) {
	    print "$xfm: ";
	    print eval "\$text->$xfm";
	    print "\n";
	  }
	}

Further information
----------

The best place to obtain definitive information about regular
expressions is from the perlre manual page that comes with every
installation of Perl. You can access this by typing

	perldoc perlre

on your command line.

You can get more information than you will ever need from *[Mastering
Regular Expressions](https://www.oreilly.com/library/view/mastering-regular-expressions/0596528124/)*, by Jeffrey Friedl (O’Reilly).

Summary
----------

*  Perl has very powerful text matching and processing facilities.

*  Often you can achieve what you want using basic text-processing functions such as [substr](https://perldoc.perl.org/functions/substr), [index](https://perldoc.perl.org/functions/index), and [uc](https://perldoc.perl.org/functions/uc).

*  Regular expressions are a more powerful method of describing text that you want to match.

*  Regular expressions are most often used in the text matching (`m//`) and text substitution (`s///`) operators.
