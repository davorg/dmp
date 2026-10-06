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
use the `substr` function. This function takes two mandatory
parameters: a string to work on and the offset to start at, and two
optional parameters: the length of the required substring and another
string to replace it with. If the third parameter is omitted, then
the substring will include all characters in the source string from
the given offset to the end. The offset of the first character in
the source string is 0. If the offset is negative then it counts
from the end of the string. Here are a few simple examples:

<!-- listing: c4/substr.pl -->

	my $string = 'Alas poor Yorick. I knew him Horatio.';
	my $sub1 = substr($string, 0, 4);    # $sub1 contains 'Alas'
	my $sub2 = substr($string, 10, 6);   # $sub2 contains 'Yorick'
	my $sub3 = substr($string, 29);      # $sub3 contains 'Horatio.'
	my $sub4 = substr($string, -12, 3);  # $sub4 contains 'him'

Many programming languages have a function that produces substrings in
a similar manner, but the clever thing about Perl’s `substr` function is
that the result of the operation can act as an lvalue. That is, you
can assign values to it, like this:

<!-- listing: c4/substr_lval.pl -->

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

<!-- listing: c4/substr_long.pl -->

	my $short = 'Short string';
	my $long = 'Very, very, very, very long';
	substr($short, 0, 5) = $long;

which will leave `$short` containing the text “Very, very, very, very
long string”.

### Finding strings within strings (index and rindex)

Two more functions that are useful for this kind of text manipulation
are index and rindex. These functions do very similar things—index
finds the first occurrence of a string in another string and rindex
finds the last occurrence. Both functions return an integer indicating
the position in the source string where the given substring begins,
and both take an optional third parameter which is the position where
the search should start. Here are some simple examples:

<!-- listing: c4/lindex.pl -->

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

<!-- listing: c4/extract.pl -->

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
eventualities. The functions are [uc](https://perldoc.perl.org/functions/uc)
(to convert a whole string to upper case),
[ucfirst](https://perldoc.perl.org/functions/ucfirst)
(to convert the first character of a string to upper case),
[lc](https://perldoc.perl.org/functions/lc)
(to convert a whole string to lower case), and
[lcfirst](https://perldoc.perl.org/functions/lcfirst)
(to convert the first character of a string to lower case).

There are a couple of traps that seem to catch unwary programmers who
use these functions. The first of these is with the `ucfirst` and
`lcfirst` functions. It is important to note that they do exactly what
they say and affect only the first character in the given string. I
have seen code like this:

	$string = ucfirst 'UPPER';
	# This doesn’t work

where the programmer expects to end up with the string 'Upper'. The
correct code to achieve this is:

	$string = ucfirst lc 'UPPER';

The second trap for the unwary involves accented and other non-ASCII
characters. Older Perl code often reaches for the `use locale` pragma
here, which makes `uc`/`lc` and various other operators follow
whatever locale is configured on the machine running the script
(via the operating system's `LANG`/`LC_*` settings), rather than
plain ASCII rules. It's a narrower fix than it looks like: it depends
on the right locale being installed and configured on every machine
the code runs on, and it doesn't know about Unicode's own case-folding
oddities, such as German's "ß", which has no single-character
uppercase form. For a more reliable, Unicode-aware approach, see
Chapter 5's coverage of `use utf8`, `fc`, and `Unicode::Collate`.

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
see the [perlre](https://perldoc.perl.org/perlre) documentation page.

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

	/[^aeiouAEIOU]/

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

These classes are a little blunter than they look once you’re dealing
with more than plain ASCII text: `\w`, for instance, matches digits
and the underscore as well as letters, and doesn’t let you restrict a
match to a particular script (Greek, say, or Cyrillic). For that level
of control Perl also provides Unicode *properties*, written
`\p{PROPERTY}` and `\P{PROPERTY}` (its negation)—see Chapter 5’s
“Unicode properties in regular expressions” for the details.

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

#### Non-greedy quantifiers

All of the quantifiers we’ve just seen—`+`, `*`, `?`, and `{n,m}`—are
*greedy* by default: they try to match as much of the string as
possible, only backing off if that’s the only way to let the rest of
the regular expression match. This usually does what you want, but
not always. Consider a string containing several pieces of text in
quotes:

	my $string = 'a "quick" and "dirty" example';
	if ($string =~ /"(.+)"/) {
	  print "Greedy: $1\n";
	}

which prints:

	Greedy: quick" and "dirty

The greedy `.+` grabs as much as it can between the first quote mark
and the last one, swallowing the closing and opening quotes of the
middle pair along the way. That’s not what we wanted—we wanted just
the first quoted piece of text. Adding a `?` after a quantifier makes
it *non-greedy* (also called *lazy*): it matches as little as
possible, only taking more if the rest of the regular expression
can’t otherwise match. So `+?`, `*?`, `??`, and `{n,m}?` are all valid.
Changing our example to use a non-greedy quantifier

	if ($string =~ /"(.+?)"/) {
	  print "Non-greedy: $1\n";
	}

now prints:

	Non-greedy: quick

which is what we were after. Non-greedy quantifiers are particularly
useful whenever you’re matching between two delimiters (quotes,
brackets, tags) and the text can contain more than one occurrence of
either delimiter.

#### Anchoring matches

It is also possible to anchor parts of your regular expression at
various points of the data. If you want to match a regular expression
only at the start of your data you can use a caret (`^`). Similarly, a
dollar sign (`$`) matches at the end of the data. To match an email
header line which consists of a string such as “From”, “To”, or
“Subject” followed by a colon, an optional space and some more text,
you could use a regular expression like this:

	/^[^:]+: ?.+$/

which matches the start of the line followed by at least one noncolon
character, followed by a colon, an optional space, and at least one
other character before the end of the line.

You could also write this as `/^.+?: ?.+$/`, using the non-greedy
quantifier we covered a couple of sections back—though in this
particular case it makes no practical difference, since a typical
header line only contains one colon. Non-greedy quantifiers matter
more when there’s more than one occurrence of whatever comes next to
choose between.

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

Perl also supports some more complex syntax that can be used in regular
expressions allowing you to define more complex rules against which
you match your strings. The full explanation of these enhancements is
in your Perl documentation, but the most important additions are:

* `(?: … )`—These parentheses group in the same way that normal brackets do, but when they match, their contents don’t get assigned to `$1`, `$2`, etc.

* `(?= … )`—This is known as positive lookahead. It enables you to check that whatever is between the parentheses exists there in the string, but it doesn’t actually consume the next part of the string that is being matched.

* `(?! … )`—This is negative lookahead, which is the opposite of positive lookahead. You will only get a match if whatever is in the parentheses does not match the string there.

* `(?<= … )`—This is positive lookbehind, the mirror image of positive lookahead: it checks that whatever is between the parentheses exists immediately *before* the current position in the string, again without consuming any of it. For example, `/(?<=\$)\d+/` matches the digits in "Price: $42" without including the dollar sign itself in the match. Unlike lookahead, what goes inside a lookbehind has to match a fixed length (Perl can't figure out how far to look backward otherwise).

* `(?<! … )`—This is negative lookbehind, the equivalent of negative lookahead but looking backward: `/(?<!foo)bar/` matches "bar" anywhere it isn't directly preceded by "foo".

* `\K`—This isn't a lookaround assertion at all, but it's often used to solve the same kind of problem: it tells the regex engine to forget everything matched so far, so it doesn't count as part of the overall match. `/\$\K\d+/` matches the same digits as the lookbehind example above, but without lookbehind's fixed-length restriction—whatever comes before `\K` can be as variable as you like. Added in Perl 5.10, `\K` is often the more flexible choice when a true lookbehind won't do the job.

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

<!-- listing: c4/mail_head.pl -->

	open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!";
	while (<$mail_fh>) {
	  print if m/^From:/;
	}

The while loop reads in another line from the file each time around
and stores the line in `$_`. The match operator checks for lines
beginning with the string “From:” (note the `^` character that matches
the start of the line) and returns true for lines that match. These
lines are then printed to `STDOUT`.

One nice touch with the match operator is that in many cases the m is
optional so we can write the match statement in our scripts as

	print if /^From:/;

and that is how you will see it in most scripts that you encounter.
It is also possible to use delimiters other than the `/` character, but
in this case the m becomes mandatory. To see why you might want to
do this, look at this example:

<!-- listing: c4/files.pl -->

	open my $fh, '<', 'files.txt' or die "Can't open files.txt: $!";
	while (<$fh>) {
	  print if /\/davec\//;
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
in all of these cases we have to use the `m` at the start of the
expression because we have moved away from using the default delimiter
of `/`.

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

<!-- listing: c4/mail_head2.pl -->

	open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!";
	while (<$mail_fh>) {
	  if (/^([^:]+): ?(.+)$/) {
	    print "Header $1 has the value $2\n";
	  }
	}

We have added two sets of brackets to the original regular expression
which will capture the header name and value into `$1` and `$2` so that
we can print them out in the next line. If a match operation is
evaluated in an array context, it returns the values of `$1`, `$2`, and
so forth in a list. We could, therefore, rewrite the previous example
as:

<!-- listing: c4/mail_head3.pl -->

	open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!";
	my ($header, $value);
	while (<$mail_fh>) {
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

#### Named captures

Numbered captures work fine for a regular expression with one or two
groups, but the more groups you add, the harder it gets to remember
which number refers to which piece of data—and if you ever insert a
new group partway through the expression, every `$1`-style variable
after it shifts down by one, silently breaking any code that relied
on the old numbering. Perl lets you give each group a name instead of
relying on its position, using `(?<name>...)` in place of a plain
`(...)`. Here’s the email header example again, rewritten to use
named captures:

	open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!";
	while (<$mail_fh>) {
	  if (/^(?<header>[^:]+): ?(?<value>.+)$/) {
	    print "Header $+{header} has the value $+{value}\n";
	  }
	}

Named captures show up in the special hash `%+`, keyed by whatever
name you gave the group, rather than in `$1`, `$2`, and so on (though
the numbered variables are still set as well, so you can mix and
match if you need to). A capture name must start with a letter and
can otherwise contain letters, digits, and underscores. Named
captures don’t change how the matching itself works—the expression
above behaves identically to `/^([^:]+): ?(.+)$/`—they just make the
code that uses the results easier to read, and far less fragile if
the expression’s structure ever changes.

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

The next two modifiers are `m` and `s`, and they’re easy to get mixed
up, because they sound similar but affect completely different parts
of the match: `m` changes what `^` and `$` do, and `s` changes what
`.` does.

By default, `^` and `$` only match at the very start and very end of
the string you’re matching against, even if that string contains
several lines separated by newlines:

	my $text = "line1\nline2";
	print "no /m: ", ($text =~ /^line2$/ ? "match" : "no match"), "\n";
	print "with /m: ", ($text =~ /^line2$/m ? "match" : "no match"), "\n";

which prints:

	no /m: no match
	with /m: match

The `m` modifier makes `^` and `$` also match at the start and end of
*every* line within the string, not just the string as a whole. (If
you need to match the very start or end of the entire string
regardless of which of these modes you’re in, the anchors `\A` and
`\z` always mean exactly that.)

By default, `.` matches any character except a newline:

	my $text2 = "a\nb";
	print "no /s: ", ($text2 =~ /a.b/ ? "match" : "no match"), "\n";
	print "with /s: ", ($text2 =~ /a.b/s ? "match" : "no match"), "\n";

which prints:

	no /s: no match
	with /s: match

The `s` modifier makes `.` match any character at all, including a
newline. `m` and `s` are entirely independent of each other, so you
can use either one, both together, or neither, depending on whether
your data spans multiple lines and whether you want `.` to see across
those line breaks.

One more modifier worth knowing about is `a`. By default, Perl’s
built-in character classes—`\d`, `\w`, `\s`, and their opposites—are
Unicode-aware, matching digits, letters, and whitespace from any
script, not just ASCII (Chapter 5 covers Perl and Unicode in a lot
more depth). The `a` modifier restricts them back down to plain
ASCII, which is useful when you specifically want to reject
non-ASCII input rather than silently accept it:

	my $arabic_digit = "\x{0663}"; # Arabic-Indic digit three
	print "no /a: ", ($arabic_digit =~ /\d/ ? "match" : "no match"), "\n";
	print "with /a: ", ($arabic_digit =~ /\d/a ? "match" : "no match"), "\n";

which prints:

	no /a: match
	with /a: no match

The next modifier is `x`. This allows you to put white space and
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
	\s?   # an optional white space character
	.+    # at least one other character
	$/x   # end of line

And that’s just a simple example!

There’s one gotcha with `x` that catches people out: whitespace
inside a bracketed character class is still significant, even though
it’s ignored everywhere else in the pattern. So if you space out a
character class for readability

	print 'e' =~ /[a e i o u]/x ? "match" : "no match", "\n";
	print ' ' =~ /[a e i o u]/x ? "match" : "no match", "\n";

both lines print `match`—the second one because you’ve accidentally
added a literal space to the list of characters being matched. The
`xx` modifier, added in Perl 5.26, closes this gap by ignoring
whitespace inside character classes too, matching what most people
expect plain `x` to do:

	print ' ' =~ /[a e i o u]/xx ? "match" : "no match", "\n";

which now correctly prints `no match`. If you actually want to match
a literal space inside an `/x` or `/xx` character class, escape it as
`\ ` or write it as `\x20`.

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

All of the match operator modifiers (`i`, `m`, `s`, `a`, `x`, and `xx`)
work in the same way on the substitution operator but there are a few
extra modifiers.
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

<!-- listing: c4/squares.pl -->

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

There’s one final modifier worth knowing, and it may well be the most
generally useful one added to Perl in the last twenty-five years: `r`.
Normally `s///` modifies the string it’s matched against in place, and
the operator itself returns a true or false value (or a count, with
`g`) to say whether anything changed, not the changed string. Add the
`r` modifier and that flips around: the original string is left
completely untouched, and `s///r` instead returns a new string with
the substitution applied, leaving you free to do whatever you like
with the result.

	my $original = 'Data Munging with Perl';
	my $updated = $original =~ s/Perl/Raku/r;
	print "Original: $original\n";
	print "Updated:  $updated\n";

which prints:

	Original: Data Munging with Perl
	Updated:  Data Munging with Raku

Without `r` you’d normally have to copy the string first and then
modify the copy, something like `(my $updated = $original) =~
s/Perl/Raku/;`, which works but reads awkwardly and is easy to get
backward. Added in Perl 5.14, `r` makes non-destructive substitution
the natural way to write the code rather than a fiddly workaround. It
works on `tr///` too, as `tr///r`, for exactly the same reason.

### Transliterating characters with tr///

Not every operator that looks like a regular expression actually is
one. `tr///` (also spelled `y///`) works completely differently from
`m//` and `s///`—it doesn’t understand any of the metacharacters,
character classes, or quantifiers we’ve just covered. Instead, it
works character by character, replacing each character in one list
with the character in the same position in a second list. The syntax
looks similar to `s///`:

	tr/SEARCHLIST/REPLACEMENTLIST/

For example, to replace every “a”, “e”, and “o” in a string with “4”,
“3”, and “0” respectively:

	my $string = 'Data Munging with Perl';
	(my $leet = $string) =~ tr/aeo/430/;
	print "$leet\n";

which prints:

	D4t4 Munging with P3rl

Notice that only lowercase “a”, “e”, and “o” were affected—`tr///`
matches characters literally, not case-insensitively, so an uppercase
letter would need its own entry in both lists if you wanted it
converted too.

`tr///` really earns its keep, though, for something `s///` can’t do
nearly as neatly: counting characters. If you leave the replacement
list empty, `tr///` doesn’t change the string at all—it just counts
how many characters matched, and returns that count:

	my $string = 'Data Munging with Perl';
	my $vowels = ($string =~ tr/aeiouAEIOU//);
	print "There are $vowels vowels in '$string'\n";

which prints:

	There are 6 vowels in 'Data Munging with Perl'

`tr///` also has a couple of useful modifiers of its own: `d` deletes
any character in SEARCHLIST that has no corresponding entry in
REPLACEMENTLIST, and `s` squeezes runs of consecutive identical
replaced characters down to a single one. Between counting,
deleting, and squeezing, `tr///` makes short work of jobs like
stripping unwanted characters or collapsing repeated whitespace,
without needing a full regular expression at all.

### Example: translating from English to American

To finish this overview of regular expressions, let’s write a script
that translates from English to American. To make it easier for
ourselves we’ll make a few assumptions.

We’ll assume that each English word has just one American translation.
We’ll also store our translations in a text file so it is easy to add
to them. The program will look something like this:

	  1: #!/usr/bin/perl
	  2: use strict;
	  3: use warnings;
	  4: use v5.36;
	  5:
	  6: while (<STDIN>) {
	  7:   s/(\w+)/translate($1)/ge;
	  8:   print;
	  9: }
	 10:
	 11: my %trans;
	 12: sub translate($word) {
	 13:   $trans{lc $word} ||= get_trans(lc $word);
	 14: }
	 15:
	 16: sub get_trans($word) {
	 17:   my $file = 'american.txt';
	 18:
	 19:   open my $trans_fh, '<', $file or die "Can't open $file: $!";
	 20:
	 21:   while (defined(my $line = <$trans_fh>)) {
	 22:     chomp $line;
	 23:     my ($english, $american) = split(/\t/, $line);
	 24:     do { $word = $american; last; } if $english eq $word;
	 25:   }
	 26:   return $word;
	 27: }

#### How the translation program works

Lines 1 to 4 are the standard way to start a Perl script today: the
shebang line, then the modern baseline of `use strict`, `use
warnings`, and a version declaration—needed here because `translate`
and `get_trans` are defined using subroutine signatures further down.

The loop starting on line 6 reads from `STDIN` and puts each line in
turn in the `$_` variable.

Line 7 does most of the work. It looks for groups of word characters.
Each time it finds one it stores the word in `$1`. The replacement
string is the result of executing the code `translate($1)`. Notice
the two modifiers: `g` which means that every word in the line will be
converted, and `e` which forces Perl to execute the replacement string
before putting it back into the original string.

Line 8 prints the value of `$_`, which is now the translated line.
Note that when given no arguments, print defaults to printing the
contents of the `$_` variable—which in this case is exactly what we
want.

Line 11 defines a caching hash which the translate function uses to
store words which it already knows how to translate.

The translate function which starts on line 12 uses a caching
algorithm similar to the Orcish Manoeuvre. If the current word doesn’t
exist in the `%trans` hash, it calls `get_trans` to get a translation
of the word. Notice that we always work with lower case versions of
the word.

Line 16 starts the `get_trans` function, which will read any necessary
words from the file containing a list of translatable words.

Line 17 defines the name of the translations file and line 19
attempts to open it. If the file can’t be opened, then the program
dies with an error message.

Line 21 loops though the translations file a line at a time, putting
each line of text into `$line`, and line 22 removes the newline
character from the line.

Line 23 splits the line on the tab character which separates the
English and American words.

Line 24 sets `$word` to the American word if the English word matches
the word we are seeking.

Line 26 returns either the translation or the original word if a
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

	hello<TAB>hiya
	pavement<TAB>sidewalk

Create another file containing the text that you want to translate.
In my test, I used

	Hello.
	Please stay on the pavement.

and running the program using the command line

	translate.pl < in.txt

produced the output

	hiya.
	Please stay on the sidewalk.

If you wanted to keep the translated text in another text file then
you could run the program using the command line

	translate.pl < in.txt > out.txt

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

	dave:x:1000:1000::/home/dave:/bin/bash

The seven sections of this line have the following meanings:

1. The username.
2. The user’s password, in encrypted form (on a system using shadow
   passwords—which is almost all of them these days—this field just
   contains an `x`, and the real encrypted password lives in
   `/etc/shadow` instead, a file only root can read).
3. The unique ID of the user on this system.
4. The ID of the user’s default group.
5. The user’s full name (strictly, this field can contain any text
   the system administrator chooses—it’s traditionally used to store
   full names, though on this particular machine mine is left blank).
6. The path to the user’s home directory.
7. The user’s command shell.

The precise meaning of some of these fields may not be clear to
non-UNIX users, but it should be clear enough to understand the
following examples.

#### Example: reading /etc/passwd

Let’s start by writing a routine to read the data into internal data
structures. This routine can then be used by any of the following
examples. As always, for flexibility, we’ll assume that the data is
coming in via `STDIN`.

<!-- listing: c4/read_passwd.pl -->

	sub read_passwd {
	  my %users;
	  my @fields = qw/name pword uid gid fullname home shell/;
	  while (<STDIN>) {
	    chomp;
	    my %rec;
	    @rec{@fields} = split(/:/);
	    $users{$rec{name}} = \%rec;
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

<!-- listing: c4/list_sh_users.pl -->

	1: use strict;
	2:
	3: my $users = read_passwd();
	4:
	5: foreach (keys %{$users}) {
	6:   print "$_\n" if $users->{$_}{shell} eq '/bin/sh';
	7: }

Again we have a very simple script. Most of the real work is being
done on line 6. This line checks the value in `$users->{$_}{shell}`
against the string “/bin/sh”, and if it matches it prints out the
current key (which is the username). Notice that we could also have
chosen to match against a regular expression using the code

	print "$_\n" if $users->{$_}{shell} =~ m|^/bin/sh$|

If performance is important to you, then you could benchmark the two
solutions and choose the faster one. Otherwise the solution you
choose is a matter of personal preference.

### A library of regular expressions

Before we go any further, it's worth knowing that you often don't
need to write a complex regular expression from scratch at all. The
CPAN module [Regexp::Common](https://metacpan.org/pod/Regexp::Common)
provides a library of ready-made, battle-tested patterns for things
you're likely to need—numbers (in various formats), delimited and
quoted strings, balanced parentheses, IPv4 and IPv6 addresses, and
dozens more—all accessed through a single `%RE` hash. It's always
worth a quick check of Regexp::Common before you reinvent one of its
patterns by hand.

Here's `$RE{num}{real}`, which matches a real number in any of the
forms Perl itself would recognize—plain integers, decimals, and
scientific notation—so you don't have to work out all of those cases
yourself:

<!-- listing: c4/regexp_common_num.pl -->

	use Regexp::Common;

	for my $candidate ('3.14', '-42', 'hello', '1e10') {
	  if ($candidate =~ /^$RE{num}{real}$/) {
	    print "$candidate: valid number\n";
	  } else {
	    print "$candidate: not a number\n";
	  }
	}

which produces:

	3.14: valid number
	-42: valid number
	hello: not a number
	1e10: valid number

`$RE{net}{IPv4}` is just as handy if you're validating configuration
data or log files:

<!-- listing: c4/regexp_common_ipv4.pl -->

	use Regexp::Common;

	for my $candidate ('192.168.0.1', '999.1.1.1', 'not an address') {
	  if ($candidate =~ /^$RE{net}{IPv4}$/) {
	    print "$candidate: valid IPv4 address\n";
	  } else {
	    print "$candidate: not a valid IPv4 address\n";
	  }
	}

Notice that `$RE{net}{IPv4}` correctly rejects `999.1.1.1`—it isn't
just checking the shape of four dot-separated numbers, it's checking
that each one is actually in the valid 0–255 range, which is exactly
the kind of fiddly detail that's easy to get wrong writing a pattern
like this yourself.

### Taking it to extremes

Of course, using regular expressions for transforming data is a very
powerful technique and, like all powerful techniques, it is open to
abuse. As an example of what you can do with this technique when you
don't hold back, let's take a brief look at the
[Text::Bastardize](http://metacpan.org/pod/Text::Bastardize)
module which is available
from the CPAN at
[http://metacpan.org/pod/Text::Bastardize](http://metacpan.org/pod/Text::Bastardize).

This module will take an innocent piece of text and will abuse it in
various increasingly bizarre ways. The complete set of
transformations available in the current version (0.08 as of the
time of writing) is as follows. That version number is also the most
recent one—Text::Bastardize hasn't been touched since 2006, so don't
expect it to have grown any newer tricks, but it still works fine as
an example:

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

<!-- listing: c4/bastardize.pl -->

	#!/usr/bin/perl
	use strict;
    use warnings;

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

If Text::Bastardize is regular expressions used for fun, [Email::Valid](https://metacpan.org/pod/Email::Valid)
is a good example of what happens when they're used in deadly earnest.
Its `rfc822` method checks an address against the full RFC 822 address
grammar using a regular expression originally developed by Jeffrey
Friedl—the same Friedl whose book is recommended above—and folded into
the module via Tom Christiansen's old `ckaddr` program. Print it out
and it runs to somewhere around a hundred lines, matching the address
grammar's full nested structure of quoted strings, comments, and
domain literals in a single expression. It's a genuinely sobering
thing to look at if you've ever thought your own regular expressions
were getting a bit long, and a good practical lesson at the same time:
validating email addresses correctly is far harder than it looks,
which is why so much real-world code settles for something much
simpler and just sends a confirmation email instead.

Further information
----------

The best place to obtain definitive information about regular
expressions is from the perlre manual page that comes with every
installation of Perl. You can access this by typing

	perldoc perlre

on your command line.

You can get more information than you will ever need from *[Mastering
Regular Expressions](https://www.oreilly.com/library/view/mastering-regular-expressions/0596528124/)*, by Jeffrey Friedl (O’Reilly). Be aware that
it's now quite old—the third edition dates from 2006, and Perl's
regex engine has moved on since then, so don't expect to find
newer features like named captures or Unicode property escapes
(`\p{...}`) in it. What it does cover, it covers in more depth than
almost anything else available, and the fundamentals haven't changed.

Summary
----------

*  Perl has very powerful text matching and processing facilities.

*  Often you can achieve what you want using basic text-processing functions such as [substr](https://perldoc.perl.org/functions/substr), [index](https://perldoc.perl.org/functions/index), and [uc](https://perldoc.perl.org/functions/uc).

*  Regular expressions are a more powerful method of describing text that you want to match.

*  Regular expressions are most often used in the text matching (`m//`) and text substitution (`s///`) operators.
