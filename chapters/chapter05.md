Part II: Data munging
=====================

In this section, we’ll encounter different forms of data challenges and
explore methods to overcome them.

First, we’ll focus on working with unstructured data, learning techniques
to identify and impose structure where none seems apparent. Next, we’ll deal
with data that’s already divided into records, showing how to break them
apart and combine them in useful ways. Finally, we’ll tackle more complex,
highly structured data, and discover advanced techniques to navigate and
manipulate it effectively.

By the end of this section, you’ll have the tools to handle various data
structures, preparing you for the more advanced topics that follow.


Chapter 5: Unstructured Data
=============================

What this chapter covers:

*  Reading a text file

*  Producing text statistics

*  Performing format conversions

*  Reformatting numbers


The simplest kind of data that can require munging is unstructured
data. This is data that has no internal structure imposed on it in
any way. In some ways this is the most difficult data to deal with as
there is often very little that you can do with it.

A good example of unstructured data is a plain text file. In this
chapter we will look at some of the things that we can do with a file
like this.

Text files
----------

A text file contains data that is readable by a person. It can
be created in a text editor like vi or emacs in UNIX, Notepad in
Windows, or edit in DOS. You should note that the files created by
most word processors are not plain text, but some proprietary
format (most word processors do have a facility to save the document
as plain text; however, this will destroy most of the
formatting of the document). It is also possible that the file could
be created by some other computer system.

A text file, like all data files, is nothing but a series of
bytes of binary data. It is only the software that you use to view
the file (an editor perhaps) that interprets the different bytes of
data as characters—we'll look at exactly how that interpretation
works later in this chapter, when we get to Unicode.

### Reading the file


One of the simplest things that we can do with a text file is to
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
coming to us via `STDIN`.

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
to disk, which will slow down your program. Then
again, if you have enough memory that you can store the entire text
of *War and Peace* in it without swapping to disk, that would be the
most efficient way to process it.


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
variable to `undef` will read the whole input stream in one go.  !!!
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
statistics. `$num_lines` and `$num_words` are the numbers of lines and
words in the file. `%words` is a hash that will keep a count of the
number of times each `%word` has occurred in the file. Its key will be the word and its value
`%will` be the number of times the word has been seen. `%lengths` is a hash that
keeps count of the frequency of word lengths in a similar fashion.

Line 8 calls our `read_text` function to get the contents of the file.

Line 10 calculates the number of lines in the file. This is simply the
number of elements in the `$text` array.

Line 12 starts to loop around each line in the array.

Line 13 increases the `$num_words` variable with the number of
elements in the `$line array`. This is equal to the number of words in
the line.

Line 15 starts to loop around the words on the line.

Lines 16 and 17 increment the relevant entries in the two hashes.

Lines 21 and 22 create two arrays which contain the keys of the `%words`
and `%lengths` hashes, sorted in the order of decreasing hash values.

Lines 24 and 25 print out the total number of words and lines in the
file.

Lines 27 and 28 print out the five most popular words in the file by
taking the first five elements in the `@sorted_words` array and
printing the value associated with that key in the `%words hash`. Lines
30 and 31 do the same thing for the `@sorted_lengths` array.

#### Example: calculating average word length

As a final example of producing text file statistics, let’s calculate
the average word length in the files. Once again we will use the
existing `read_text` function to read in our text.

	my ($total_length, $num_words);
	my $text = read_text();
	my ($word, $line);
	foreach $line (@{$text}) {
	  $num_words += scalar @{$line};
	  foreach $word (@{$line}) {
	    $total_length += length $word;
	  }
	}
	printf "The average word length is %.2f\n",
	  $total_length / $num_words;

Data conversions
----------------

One of the most useful things that you might want to do to
unstructured data is to perform simple data format conversions on it.
In this section we’ll take a look at three typical types of
conversions that you might need to do.

### Converting the character set

These days, most textual data you come across will already be
Unicode, usually encoded as UTF-8—but you will still run into other
character sets and encodings from time to time, especially from older
systems or specific regional formats. Multibyte characters, in
particular, are increasingly the norm rather than the exception,
especially if you are dealing with data from a country where they are
commonplace (like China or Japan).

#### Unicode

For multibyte characters, the modern story is straightforward, but it
wasn't always. Perl 5.6 (released in 2000) introduced the `utf8`
pragma, and older editions of this book pointed readers without
access to it at the
[Unicode::Map8](https://metacpan.org/pod/Unicode::Map8) and
[Unicode::String](https://metacpan.org/pod/Unicode::String) modules.
Both of those are long gone from active use—`utf8` has been part of
every Perl release for well over two decades, and the tool you
actually reach for to convert between encodings is
[Encode](https://metacpan.org/pod/Encode), which has shipped with
Perl's core distribution since 5.8 (2002).

It helps to be clear about what each of these actually does, because
they solve different problems:

*  [utf8](https://metacpan.org/pod/utf8) tells Perl that *your source
   code* is written in UTF-8, so that literal Unicode characters in
   string literals—and, since Perl 5.10, in identifiers—are understood
   correctly. It has nothing to do with reading or writing files.

*  [Encode](https://metacpan.org/pod/Encode), and the `:encoding(...)`
   layer it provides for filehandles, is what actually converts bytes
   on disk (or from a network connection, or `STDIN`) into Perl's
   internal Unicode strings, and back again.

##### Bytes versus Unicode strings

Before any of this makes sense, it helps to be clear about the
difference between two things that are easy to conflate: bytes and
characters.

Outside your program—on disk, in a network packet, on `STDIN`—there is
no such thing as a "Unicode string." There are only bytes: numbers
between 0 and 255. A byte doesn't know what character it represents;
that meaning only exists once you've agreed on an *encoding*, a
mapping from byte sequences to characters. Inside your program, once
Perl has decoded those bytes using the right encoding, you have a
Unicode string—a sequence of *characters* (strictly, code points),
which Perl represents however it likes internally, and which you never
need to think about as bytes again until you write it back out.

ASCII was the original encoding: 128 characters, each one byte, values
0–127. UTF-8 is Unicode's most common encoding, and it was
deliberately designed to be backwards compatible with ASCII: code
points 0–127 are represented by the exact same single byte as they
always were in ASCII. Any byte value 128 or higher signals "this byte
is part of a multi-byte sequence, keep reading"—real UTF-8 text
containing, say, "café", uses a two-byte sequence for the é. This is
why every valid ASCII file is automatically valid UTF-8: for that
range, the two encodings are identical.

It's also why this doesn't hold for encodings like ISO-8859-1
(Latin-1) and its relatives. Those are *also* single-byte encodings,
and they *also* agree with ASCII for 0–127—but for byte values
128–255, they assign single, specific characters ("é" is byte 233 in
Latin-1). UTF-8 uses those exact same byte values for a completely
different purpose: not standalone characters, but signals about
multi-byte sequences. Feed Latin-1 bytes to something expecting UTF-8
(or the reverse), and you get either an outright decoding error
or—worse—something that "successfully" decodes into complete garbage.
That collision, more than anything else, is where the classic mojibake
you'll have seen in broken web pages and emails comes from.

This is exactly what the `:encoding(...)` layer in "patrol your
borders" is for: it's the one place in your program that has to know
which byte-level encoding your data is actually in, so it can
translate correctly at the boundary. Get that one fact right, and
everything inside the border—string functions, regular expressions,
sorting, comparisons—just works on characters, with no bytes in sight.

##### "Patrol your borders"

The single most useful rule for working with Unicode text, in any
language, is this: decode incoming data into Unicode as soon as it
enters your program, work with genuinely decoded Unicode strings
throughout the body of the program, and encode back into bytes only at
the point where data leaves your program—printing to a screen, writing
to a file, sending it across a network. This is sometimes called the
"Unicode sandwich" (decode, process, encode), but I like to think of
it as patrolling your borders: control what crosses the boundary in
and out, and don't worry about encoding anywhere in between.

Here's what that looks like reading a short file of artist names and
printing them in upper case:

	use strict;
	use warnings;

	open my $in, '<:encoding(UTF-8)', 'artists.txt'
	    or die "Can't open artists.txt: $!";

	binmode STDOUT, ':encoding(UTF-8)';

	while (my $artist = <$in>) {
	  chomp $artist;
	  print uc($artist), "\n";
	}

Given a file containing:

	Björk
	Sigur Rós
	Café Tacvba
	Mötley Crüe
	Beyoncé

this prints:

	BJÖRK
	SIGUR RÓS
	CAFÉ TACVBA
	MÖTLEY CRÜE
	BEYONCÉ

Notice that [uc](https://perldoc.perl.org/functions/uc) just works
correctly on the accented characters, upper-casing "ö" to "Ö" and "é"
to "É"—and so would a regular expression using `\w` or `\b`, from
[Chapter 4](ch007.xhtml). That's the entire payoff of getting the
borders right: once a string has been properly decoded, every built-in
string operation and every regular expression feature you already know
behaves exactly as you'd expect against non-ASCII text, with no
special cases to remember. Skip the `:encoding(UTF-8)` layer on the
way in, and the same code will silently mangle every accented
character instead—which is exactly where the classic "mojibake"
garbage you'll have seen in badly configured web pages and emails
comes from.

##### A silly example: Unicode in your source code

Because [utf8](https://metacpan.org/pod/utf8) is about your source
code rather than your data, it lets you do things that have nothing to
do with file I/O—including, since Perl 5.10, using Unicode characters
in identifiers:

	use strict;
	use warnings;
	use utf8;

	binmode STDOUT, ':encoding(UTF-8)';

	my $π = 3.14159;
	my $r = 5;

	print "A circle of radius $r has an area of ", $π * $r ** 2, "\n";

This prints:

	A circle of radius 5 has an area of 78.53975

I wouldn't recommend actually naming your variables after Greek
letters in production code—but it's a good illustration of what the
`utf8` pragma is really for. Leave it out, and Perl doesn't understand
`$π` as a variable name at all:

	Can't use global $π in "my" at greek_pi.pl line 8, near "my $π"

##### Other ways to represent Unicode characters

Typing a literal character like `π` or `é` straight into your source,
as in the example above, is the most direct approach, but it isn't
always practical—your editor or terminal might not make the character
easy to type, or you might want your source file to stay pure ASCII
regardless of what data it works with. Perl gives you a few other ways
to write a specific Unicode character, all of which work inside
double-quoted strings and regular expressions (though not inside
single-quoted strings, which never interpolate escapes):

*  `\x{HHHH}`—the character at the given hexadecimal code point.
   `"\x{3C0}"` is `π`; `"\x{E9}"` is `é`. This is the same `\x` escape
   Perl has always had, just with braces added so it can go beyond a
   single byte.

*  `\N{U+HHHH}`—the same thing, written the way the Unicode standard
   itself usually writes code points. `"\N{U+3C0}"` and `"\x{3C0}"` are
   identical.

*  `\N{CHARACTER NAME}`—the character's official Unicode name, in full
   capitals. `"\N{GREEK SMALL LETTER PI}"` and
   `"\N{LATIN SMALL LETTER E WITH ACUTE}"` are more verbose, but
   self-documenting: a reader (or a search of the source) doesn't need
   to decode a hex number to know what character is meant. This has
   worked without any extra `use` statement since Perl 5.16—older code
   you come across may still have an explicit `use charnames ':full';`
   at the top, which is now only needed if you want to define your own
   custom character aliases.

None of these need `use utf8;`—unlike the `$π` example, they're
spelled entirely in ASCII in your source file, so there's nothing for
the source encoding to affect. That makes them a good choice whenever
you want to embed a specific character without committing the rest of
the file to being UTF-8, or when the character in question doesn't
have an easy-to-type keyboard representation at all.

	use strict;
	use warnings;

	binmode STDOUT, ':encoding(UTF-8)';

	print "\x{2764}\n";                    # ❤ (Heavy Black Heart)
	print "\N{U+2603}\n";                  # ☃ (Snowman)
	print "\N{GREEK SMALL LETTER PI}\n";   # π

##### Unicode properties in regular expressions

We already saw, back in "Patrol your borders," that once a string is
properly decoded, familiar regex shorthands like `\w` and `\b` just
work correctly against accented and non-Latin text. But `\w` is a
blunt instrument—it matches letters, digits, *and* underscore, in any
script, all lumped together. Sometimes you need more precision than
that, and Perl's regex engine gives it to you through Unicode
*properties*: `\p{PROPERTY}` matches any character that has the named
property, and `\P{PROPERTY}` (capital P) matches any character that
doesn't.

The property you'll reach for most often is `\p{L}`—any letter, in any
script, and nothing else:

	use strict;
	use warnings;
	use utf8;

	my $ident = 'foo_1';
	print $ident =~ /^\w+$/    ? "matches \\w\n"    : "no match\n";
	print $ident =~ /^\p{L}+$/ ? "matches \\p{L}\n" : "no match\n";

which prints:

	matches \w
	no match

`\w` happily matches the underscore and the digit; `\p{L}` only
matches actual letters, which makes it a better choice for something
like validating that a name field really is a name.

Properties also let you ask questions that `\w`, `\d`, and `\s` simply
can't answer at all—like whether a string is written in a particular
script:

	my $greek = 'χρόνος';
	print $greek =~ /^\p{Greek}+$/ ? "all Greek\n" : "not all Greek\n";

	print 'café' =~ /^\p{Greek}+$/ ? "all Greek\n" : "not all Greek\n";

which prints:

	all Greek
	not all Greek

There are hundreds of properties defined—scripts (`Greek`, `Han`,
`Cyrillic`), general categories (`Nd` for decimal digit, `Lu` for
uppercase letter), and more besides—see
[perluniprops](https://perldoc.perl.org/perluniprops) for the full
list. Negating one with `\P{...}` is a quick way to strip out
everything that isn't a letter, regardless of script:

	(my $stripped = 'Björk-1975!') =~ s/\P{L}//g;
	print "$stripped\n";  # Björk

##### Combining characters and canonical representation

There's a wrinkle in all of this that catches people out: the same
visually identical piece of text can be represented by more than one
different sequence of Unicode code points. The "é" in "café" can be a
single, pre-composed code point (U+00E9,
`LATIN SMALL LETTER E WITH ACUTE`), or it can be two code points: a
plain "e" (U+0065) followed by a *combining* acute accent (U+0301,
`COMBINING ACUTE ACCENT`), which visually stacks on top of the
character before it. Both render identically. Neither is "wrong." But
as far as Perl (or any program) is concerned, they are different
strings:

	use strict;
	use warnings;
	use utf8;

	my $precomposed = "caf\x{E9}";     # e with acute, one code point
	my $decomposed   = "cafe\x{301}";  # e, then a combining acute accent

	print "Same string: ", ($precomposed eq $decomposed ? 'yes' : 'no'), "\n";
	print "Same length: ", (length($precomposed) == length($decomposed) ? 'yes' : 'no'), "\n";

which prints:

	Same string: no
	Same length: no

even though both print as "café" and look completely indistinguishable
to a human. This is called *canonical equivalence*, and it's a common
source of bugs when comparing strings, sorting them, or using them as
hash keys—two "identical-looking" filenames, usernames, or search
terms can silently fail to match. (It's also a genuinely common
real-world gotcha: macOS has historically favored the decomposed form
for filenames, so text typed on a Mac and text typed almost anywhere
else can carry the same content in different forms.)

The fix is *normalization*: converting text to one standard
representation before you compare it. The core module
[Unicode::Normalize](https://metacpan.org/pod/Unicode::Normalize)
(bundled with Perl since 5.7.3) provides four standard forms, but the
one you'll want most often is `NFC`, which composes characters
together wherever possible:

	use strict;
	use warnings;
	use utf8;
	use Unicode::Normalize;

	my $precomposed = "caf\x{E9}";
	my $decomposed   = "cafe\x{301}";

	print "Before: ", ($precomposed eq $decomposed ? 'yes' : 'no'), "\n";
	print "After:  ", (NFC($precomposed) eq NFC($decomposed) ? 'yes' : 'no'), "\n";

which prints:

	Before: no
	After:  yes

The rule of thumb: normalize with `NFC` at the same border where
you're already decoding—as part of getting data into a known-good
state before you do anything else with it, right alongside deciding on
an encoding in the first place.

##### Comparing and sorting Unicode text: fold case and collation

Normalization fixes one kind of comparison problem—the same character
represented by different code point sequences. But even fully
normalized Unicode text can trip up the string comparisons you're
used to, in two different ways: case-insensitive matching, and
sorting.

Perl's `lc` and `uc` work fine for simple, one-to-one case
conversion—even on accented Unicode letters—but some languages have
case relationships that aren't one-to-one at all. German is the
classic example: the letter "ß" (`LATIN SMALL LETTER SHARP S`)
has no uppercase form of its own—its uppercase equivalent is the
two-letter sequence "SS". `lc` doesn't know this, so it fails to match
things a human reader would consider the same word:

	use strict;
	use warnings;
	use utf8;
	use feature 'fc';

	my @words = ('straße', 'STRASSE');

	print "lc: ", (lc($words[0]) eq lc($words[1]) ? 'equal' : 'not equal'), "\n";
	print "fc: ", (fc($words[0]) eq fc($words[1]) ? 'equal' : 'not equal'), "\n";

which prints:

	lc: not equal
	fc: equal

`fc` (case *fold*, rather than case *convert*) implements Unicode's
full case-folding algorithm, which knows about expansions like this
one. It's a core function, available since Perl 5.16 with
`use feature 'fc'` (or simply `use v5.16;` or later). Use `fc` instead
of `lc` any time you're comparing Unicode text for equality, case
insensitively—for example, deduplicating usernames or matching search
terms.

Sorting has a similar problem. Perl's default `sort` (and `cmp`)
compares strings by code point, and accented characters generally
have code points well outside the ASCII letters, so they end up in
the wrong place:

	use strict;
	use warnings;
	use utf8;
	use Unicode::Collate;

	binmode STDOUT, ':encoding(UTF-8)';

	my @words = ('über', 'apple', 'zebra');

	print "Default sort:  ", join(', ', sort @words), "\n";

	my $collator = Unicode::Collate->new;
	print "Collated sort: ", join(', ', $collator->sort(@words)), "\n";

which prints:

	Default sort:  apple, zebra, über
	Collated sort: apple, über, zebra

Plain `sort` puts "über" last, because "ü" (U+00FC) sits after every
plain ASCII letter in code point order—not where a human alphabetizing
a list would put it. [Unicode::Collate](https://metacpan.org/pod/Unicode::Collate),
core since Perl 5.8.0, implements the Unicode Collation Algorithm,
which sorts text the way people actually expect, taking accents,
language conventions, and much more into account. It's the module to
reach for any time you're presenting a sorted list of names, titles,
or other Unicode text to a human reader.

##### Simplifying Unicode with Text::Unidecode

Sometimes you don't need to preserve Unicode text faithfully—you just
need something ASCII-safe to fall back on: a filename, a URL slug, a
sort key, or output for a system with no Unicode support at all. The
CPAN module [Text::Unidecode](https://metacpan.org/pod/Text::Unidecode)
does a rough-and-ready transliteration of Unicode text into plain
ASCII:

	use strict;
	use warnings;
	use utf8;
	use Text::Unidecode qw(unidecode);

	binmode STDOUT, ':encoding(UTF-8)';

	my @artists = ('Björk', 'Sigur Rós', 'Café Tacvba', 'Mötley Crüe');

	foreach my $artist (@artists) {
	  print unidecode($artist), "\n";
	}

which gives you:

	Bjork
	Sigur Ros
	Cafe Tacvba
	Motley Crue

This is a blunt tool—it's context-insensitive, and its own
documentation is upfront that it does badly on some writing systems
(Japanese especially)—so treat it as a fallback of last resort, not a
substitute for handling Unicode properly. Reach for it only once
you've decided you genuinely don't need the original characters, not
as a shortcut to avoid learning the borders rule above.

We'll come back to this when we look at JSON and YAML in
[Chapter 10](ch015.xhtml)—both formats assume UTF-8 by default, and
getting the borders right here is exactly what makes that just work.

### Converting line endings

As I mentioned above, a text file is no more than a stream of
binary data. It is only the software that we use to process it that
interprets the data in such a way that it produces lines of text. One
important character (or sequence of characters) in a text file is the
character which separates different lines of text. When, for example,
a text editor reaches this character in a file, it will know that the
following characters must be displayed starting at the first column of
the following line of the user’s display.

#### Different line end characters

Over the years, two characters in particular have come to be the most
commonly used line end characters. They are the characters with the
ASCII codes 10 (line feed) and 13 (carriage return). The line feed is
used by UNIX (and Linux) systems. Apple Macintoshes use the carriage
return. DOS and Windows use a combination of both characters, the
carriage return followed by the line feed.

This difference in line endings causes no problems when data files are
used on the same system on which they were created, but when you start
to transfer data files between different systems it can lead to some
confusion. You may have edited a file that was created under Windows
in a UNIX text editor. If so you will have seen an extra `^M`
character at the end of each line of text (this is
becoming less common as many editors will now display the lines
without the ^M, and indicate the newline style in the status line).
This is the printable equivalent of the carriage return character that
Windows inserts before each line feed. Similarly, a UNIX text file
opened in Windows Notepad will have no carriage returns before the
line feed and, therefore, Notepad will not recognize the end of line
character sequence. All the lines will subsequently be run together,
separated only by a black rectangle, which is Windows’ way of
representing the unprintable line feed character.

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

In the program, instead of using `\n` and `\r` we use the ASCII control
character sequences `\cM` and `\cJ` (Ctrl-M and Ctrl-J). This is
because Perl is cleverer than we might like it to be in this case.
Whenever Perl sees a `\n` sequence in a program it actually converts
it to the correct end-of-line character sequence for the current
system. This is very useful most of the time (it means, for example,
that you don’t need to use `print "some text\r\n";` to output text
when using Perl on a Windows system). But in this situation it masks
the very problem that we’re trying to solve—so we have to go to a
lower level representation of the characters.

	#!/usr/local/bin/perl
	use strict;
    use warnings;

	(@ARGV == 2) or die "Error: source and target formats not given.";

	my ($src, $tgt) = @ARGV;

	my %conv = (CR => "\cM",
	            LF => "\cJ",
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

To match natural numbers (*i.e.*, positive integers) you can use a
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

	my $num_re = qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/;
	my @nums;
	while ($data =~ /$num_re/g) {
	  push @nums, $1;
	}

to print out a list of all of the numbers in $data.

If you have a function, reformat, that will change the numbers into
your preferred format then you can use code like this:

	$data =~ s/$num_re/reformat($1)/ge;

which makes use, once more, of the `e` modifier to execute the
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
[Convert::SciEng](https://metacpan.org/pod/Convert::SciEng) and [Number::Format](https://metacpan.org/pod/Number::Format).

#### Convert::SciEng

[Convert::SciEng](https://metacpan.org/pod/Convert::SciEng) is a module for converting numbers to and from a
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
whenever a value is required. The default format is `%5.5g`.

There is, of course, also a fix method that takes a number and
returns a value with the correct postfix letter appended:

	print $conv->fix(100_000)

prints “100K” and

	print $conv->fix(1_000_000)

prints “1M”.

#### Number::Format

The [Number::Format](https://metacpan.org/pod/Number::Format) module is a more general-purpose module for
formatting numbers in interesting ways. Like [Convert::SciEng](https://metacpan.org/pod/Convert::SciEng), it is
accessed through an object-oriented interface. Calling the new method
creates a new formatter object. This method takes as its argument a
hash which contains various formatting options. These options are
detailed in [Appendix A](ch018.xhtml) along with the other object methods contained
within [Number::Format](https://metacpan.org/pod/Number::Format).

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

	my $fmt = Number::Format->new(INTL_CURRENCY_SYMBOL => 'GBP',
	                              DECIMAL_DIGITS => 1);
	my $number = 1234567.890;
	print $fmt->round($number), "\n";
	print $fmt->format_number($number), "\n";
	print $fmt->format_negative($number), "\n";
	print $fmt->format_picture($number, '###########'), "\n";
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

It is, of course, possible to combine [Number::Format](https://metacpan.org/pod/Number::Format) with some of the
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
	my $num_re = qr/[-+]?(?=\d|\.\d)\d*(\.\d*)?([eE]([-+]?\d+))?/;
	$data =~ s/$num_re/$fmt->format_number($1)/ge;
	print $data;

Further information
-------------------

For more information about input control variables such as `$/`, see
the [perlvar](https://perldoc.perl.org/perlvar) manual page.

For more information about the Unicode support in Perl, see the
[perlunicode](https://perldoc.perl.org/perlunicode) and [utf8](https://metacpan.org/pod/utf8) manual pages,
and `perldoc Encode` for the module that does the actual encoding and
decoding work. [Text::Unidecode](https://metacpan.org/pod/Text::Unidecode)
is available from the CPAN.

For more information about sprintf, see the [sprintf](https://perldoc.perl.org/functions/sprintf) manual
page. Both [Convert::SciEng](https://metacpan.org/pod/Convert::SciEng) and [Number::Format](https://metacpan.org/pod/Number::Format) can be found on the
CPAN.

Once you have installed them, their documentation will be available
using the `perldoc` command.

Summary
-------

*  Most unstructured data is found in plain text files, usually encoded as UTF-8 these days.

*  Perl can be used to extract statistics from text files very easily.

*  Many useful data format conversions can be carried out either using the standard Perl distribution or with the addition of modules from the CPAN.
