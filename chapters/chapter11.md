Chapter 11: Building your own parsers
=====================================

What this chapter covers:

*  Creating your own parser

*  Returning parsed data

*  Matching grammar rules

*  Building a data structure to return

*  Parsing complex file formats into complex data structures



The prebuilt parsers that we have looked at in the two previous
chapters are, of course, very useful, but there are many times when
you need to parse data in a format for which a prebuilt parser does
not exist. In these cases you can create your own parser using a
number of Perl modules. The most flexible of these is
Parse::RecDescent, and in this chapter we take a detailed look at its
use.

Introduction to Parse::RecDescent
---------------------------------

Parse::RecDescent is a tool for building top-down parsers which was
written by Damian Conway. It doesn’t form a part of the standard Perl
distribution, so you will need to get it from the CPAN. It can be
found at http://www.cpan.org/modules/by-module/Parse/. The module
comes with copious documentation and more example code than anyone
would ever want to read.

Using Parse::RecDescent is quite simple. In summary you define a
grammar for the parser to use, create a parser object to process the
grammar, and then pass the text to be parsed to the parser. We’ll see
more specific examples later, but all the programs will have a basic
structure which looks like this:

	use Parse::RecDescent;
	my $grammar = q(
	# Text that define your grammar
	);
	my $parser = Parse::RecDescent->new($grammar);
	my $text = q(
	# Scalar which contains the text to be parsed
	);
	# top_rule is the name of the top level rule in you grammar.
	$parser->top_rule($text);

### Example: parsing simple English sentences


For example, if we go back to the example of simple English sentences
which we used in chapter 8, we could write code like this in order to
check for valid sentences.

	use Parse::RecDescent;
	my $grammar = q(
	sentence: subject verb object
	subject: noun_phrase
	object: noun_phrase
	verb: 'wrote' | 'likes' | 'ate'
	noun_phrase: pronoun | proper_noun | article noun
	article: 'a' | 'the' | 'this'
	pronoun: 'it' | 'he'
	proper_noun: 'Perl' | 'Dave' | 'Larry'
	noun: 'book' | 'cat'
	);
	my $parser = Parse::RecDescent->new($grammar);
	while (<DATA>) {
	chomp;
	print "'$_' is ";
	print 'NOT ' unless $parser->sentence($_);
	print "a valid sentencen";
	}
	__END__
	Larry wrote Perl
	Larry wrote a book
	Dave likes Perl
	Dave likes the book
	Dave wrote this book
	the cat ate the book
	Dave got very angry

Notice that we have expanded the terminals to actually represent a
(very limited) subset of English words. The output of this script is a
follows:

	'Larry wrote Perl' is a valid sentence
	'Larry wrote a book' is a valid sentence
	'Dave likes Perl' is a valid sentence
	'Dave likes the book' is a valid sentence
	'Dave wrote this book' is a valid sentence
	'the cat ate the book' is a valid sentence
	'Dave got very angry' is NOT a valid sentence

Which shows that “Dave got very angry” is the only text in our data,
which is not a valid sentence. !!! FOOTNOTE 1 By the rules of our
grammar of course—not by the real rules of English.!!!

#### Explaining the code

The only complex part of this script is the definition of the grammar.
The syntax of this definition is similar to one that we used in
chapter 8. The only major difference is that we have replaced the
arrow -> with a colon. If you read the rules, replacing the colon with
the phrase “is made up of” and the vertical bar with the word “or”,
then these rules are easy to understand.

In this example all of our terminals are fixed strings. As we shall
see later in the chapter, it is quite possible to match Perl regular
expressions instead.

Having defined our grammar, we simply create a parser object using
this gram- mar and use that object to see if our sentences are valid.
Notice that we use the method sentence to validate each sentence in
turn. This method was created by the Parse::RecDescent object as it
read our grammar. The sentence method returns true or false depending
on whether or not the parser object successfully parsed the input
data.

Returning parsed data
---------------------

The previous example is all very well if you just want to know
whether your data meets the criteria of a given grammar, but it
doesn’t actually produce any useful data structures which represent
the parsed data. For that we have to look a little deeper into
Parse::RecDescent.

### Example: parsing a Windows INI file

Let’s look at parsing a Windows INI file. These files contain a
number of named sections. Each of these sections contain a number of
assignment statements. Figure 11.1 shows an example INI together with
the various parts that make up the file structure.

![INI File Structure](images/11-1-ini-file-structure.png)

In this example we have sections called “files” and “rules.” The
files section lists the names of the input and output files together
with their extension; the rules section lists a number of
configuration options. This file might be used to control the
configuration of a text-processing program.

Before looking at how we would get the data out, it is a good idea to
decide what data structure we are going to use to store the parsed
data. In this case it seems fairly obvious that a hash of hashes
would be most useful. Each key within the first hash would be a
section name and the value would be a reference to another hash.
Within these second-level hashes the keys would be the left-hand side
of the assignment statement and the values would be the right-hand
side. Figure 11.2 shows this data structure.

![INI file data structure](images/11-2-ini-file-data-structure.png)

This means that you can get an individual value very easily using code
like:

	$input_file = $Config{files}{input};

### Understanding the INI file grammar

Let’s take a look at a grammar that defines an INI file. We’ll use
the syntax found in Parse::RecDescent.

	file: section(s)
	section: header assign(s)
	header: '[' /\w+/ ']'
	assign: /\w+/ '=' /\w+/

The grammar can be explained in English like this:

*  An INI file consists of one or more sections.

*  Each section consists of a header followed by one or more assignments.

*  The header consists of a [ character, one or more word characters, and a ] character.

*  An assignment consists of a sequence of one or more word characters, an = character, and another sequence of one or more word characters.

#### Using subrule suffixes\

There are a couple of new features to notice here. First, we have used
(s) after the names of some of our subrules. This means that the
subrule can appear one or more times in the rule. There are a number
of other suffixes which can control the num- ber of times that a
subrule can appear, and the full list is in table 11.1. In this case
we are saying that a file can contain one or more sections and that
each section can contain one or more assignment statements.

Table 11.1 Optional and repeating subrules

| Subrule suffix | Meaning                                                    |
|----------------|------------------------------------------------------------|
| (?)            | Optional subrule. Appears zero or one time.                |
| (s)            | Mandatory repeating subrule. Appears one or more times.    |
| (s?)           | Optional repeating subrule. Appears zero or more times.    |
| (N)            | Repeating subgroup. Must appear exactly *N* times.         |
| (N..M)         | Repeating subgroup. Must appear between *N* and *M* times. |
| (..M)          | Repeating subgroup. Must appear between 1 and *M* times.   |
| (N..)          | Repeating subgroup. Must appear at least *N* times.        |



#### Using regular expressions\

The other thing to notice is that we are using regular expressions in
many places to match our terminals. This is useful because the names
of the sections and the keys and values in each section can be any
valid word. In this example we are saying that they must all be a
string made up of Perl’s word characters. !!! FOOTNOTE 2 That is,
alphanumeric characters and the underbar character.!!!

### Parser actions and the @item array

In order to extract data, we can make use of parser actions. These
are pieces of code that you write and then attach to any rule in a
grammar. Your code is then executed whenever that rule is matched.
Within the action code a number of special variables are available.
The most useful of these is probably the @item array which contains a
list of the values that have been matched in the current rule. The
value in $item[0] is always the name of the rule which has matched.
For example, when our header rule is matched, the @item array will
contain “header”, “[”, the name of the section, and “]” with elements
0 to 3 !!!FOOTNOTE 3 The same information is also available in a hash called %item, but I’ll use @item in these examples. For more details on %item see perldoc Parse::RecDescent.
!!! (figure 11.3).

![The @item array after matching the header rule for the first time](images/11-3-item-array.png)

In order to see what values are being matched, you could put action
code on each of the rules in the grammar like the following code. All
this code does is print out the contents of the @item array each time
a rule is matched.

 file: section(s) { print "$item[0]: $item[1]\n"; }
 section: header assign(s) { print "$item[0]: $item[1] $item[2]\n"; }
 header: '[' /\w+/ ']' { print "$item[0]: $item[1] $item[2] $item[3]\n"; }
 assign: /\w+/ '=' /\w+/ { print "$item[0]: $item[1] $item[2] $item[3]\n"; }

However, Parse::RecDescent provides an easier way to achieve the same
result, by providing a way to assign a default action to all rules in
a grammar. If you assign a string containing code to the variable
$::RD_AUTOACTION, then that code will be assigned to every rule which
doesn’t have an explicit action.

### Example: displaying the contents of @item

Here is a sample program which reads an INI file and displays the
contents of @item for each matched rule.

	 use Parse::RecDescent;
	 my $grammar = q(
	 file: section(s)
	 section: header assign(s)
	 header: '[' /\w+/ ']'
	 assign: /\w+/ '=' /\w+/
	 );
	 $::RD_AUTOACTION = q { print "$item[0]: @item[1..$#item]\n"; 1 };
	 $parser = Parse::RecDescent->new($grammar);
	 my $text;
	 {
	 $/ = undef;
	 $text = <STDIN>;
	 }
	 $parser->file($text);

The general structure of the code and the grammar should be familiar.
The only thing new here is the code assigned to $::RD_AUTOACTION.
This code will be run whenever a rule that doesn’t have its own
associated action code is matched. When you run this program using
our earlier sample INI file as input, the resulting output is as
follows:

	header: [ files ]
	assign: input = data_in
	assign: output = data_out
	assign: ext = dat
	section: 1 ARRAY(0x8adc868)
	header: [ rules ]
	assign: quotes = double
	assign: sep = comma
	assign: spaces = trim
	section: 1 ARRAY(0x8adc844)
	file: ARRAY(0x8adc850)

#### How rule matching works\

The previous example shows us a couple of interesting things about the
way that Parse::RecDescent works. Look at the order in which the rules
have been matched and recall what we saw about the workings of
top-down parsers in chapter 8. Here you can clearly see that a rule
doesn’t match until all of its subrules have been matched
successfully.

 Secondly, look at the output for the section and file rules. Where
 you have matched a repeating subrule, @item contains a reference to
 an array, and where you have matched a nonrepeating subrule, @item
 contains the value 1. This shows us something about what a matched
 rule returns. Each matched rule returns a true value. By default this
 is the number 1, but you can change this in the associated action
 code. Be sure that your code has a true return value, or else the
 parser will think that the match has failed.

### Returning a data structure

The value that is returned from the top-level rule will be the value
returned by the top-level rule method when called by our script. We
can use this fact to ensure that the data structure that we want is
returned. Here is the script that will achieve this:

	use Parse::RecDescent;
	my $grammar = q(
	file: section(s)
	{ my %file;
	foreach (@{$item[1]}) {
	$file{$_->[0]} = $_->[1];
	}
	\%file;
	}
	section: header assign(s)
	{ my %sec;
	foreach (@{$item[2]}) {
	$sec{$_->[0]} = $_->[1];
	}
	[ $item[1], \%sec]
	}
	header: '[' /\w+/ ']' { $item[2] }
	assign: /\w+/ '=' /\w+/
	{ [$item[1], $item[3]] }
	);
	$parser = Parse::RecDescent->new($grammar);
	my $text;
	{
	$/ = undef;
	$text = <STDIN>;
	}
	my $tree = $parser->file($text);
	foreach (keys %$tree) {
	print "$_\n";
	foreach my $key (keys %{$tree->{$_}}) {
	print "\t$key: $tree->{$_}{$key}\n";
	}
	}

The code that has been added to the previous script is in two places.
First (and most importantly) in the parser actions and, secondly, at
the end of the script to display the returned data structure and
demonstrate what is returned.

The action code might look a little difficult, but it’s probably a
bit easier if you read it in reverse order and see how the data
structure builds up.

The assign rule now returns a reference to a two-element list. The
first element is the left-hand side of the assignment and the second
element is the right-hand side. The header rule simply returns the
name of the section.

The section rule creates a new hash called %sec. It then iterates
across the list returned by the assign subrule. Each element in this
list is the return value from one assign rule. As we saw in the
previous paragraph, this is a reference to a two- element list. We
convert each of these lists to a key/value pair in the
%sec hash. Finally, the rule returns a reference to a two-element
%hash. The first
element of this list is the return value from the header rule (which
is the section name), and the second element is a reference to the
section hash.

The file rule uses a very similar technique to take the list of
sections and convert them into a hash called %file. It then returns
the %file hash.

This means that the file method returns a reference to a hash. The
keys to the hash are the names of the sections in the file and the
values are references to hashes. The keys to the second level hashes
are the text from the left-hand side of the assignments, and the
values are the associated strings from the right-hand side of the
assignment.

The code at the end of the script prints out the values in the
returned data struc- ture. Running this script against our sample INI
file gives us the following result:

	rules
	quotes: double
	sep: comma
	spaces: trim
	files
	input: data_in
	ext: dat
	output: data_out

which demonstrates that we have built up the data structure that we
wanted.

Another example: the CD data file
---------------------------------

Let’s take a look at another example of parsing a data file with
Parse::RecDescent. We’ll take a look at how we’d parse the CD data
file that we discussed in chapter 8. What follows is the data file we
were discussing:

	Dave's CD Collection
	16 Sep 1999

	Artist        Title              Label          Released
	--------------------------------------------------------
	Bragg, Billy  Workers' Playtime  Cooking Vinyl  1988
	+She's Got A New Spell
	+Must I Paint You A Picture
	Bragg, Billy  Mermaid Avenue     EMI            1998
	+Walt Whitman's Niece
	+California Stars
	Black, Mary   The Holy Ground    Grapevine      1993
	+Summer Sent You
	+Flesh And Blood
	Black, Mary   Circus             Grapevine      1995
	+The Circus
	+In A Dream
	Bowie, David  Hunky Dory         RCA            1971
	+Changes
	+Oh You Pretty Things
	Bowie, David  Earthling          EMI            1997
	+Little Wonder
	+Looking For Satellites

	6 Records

In chapter 8 we came up with a rather unsatisfying way to extract the
data from this file and put it into a data structure. Now that
Parse::RecDescent is in our toolkit, we should be able to come up with
something far more elegant.

As with the last example, the best approach is to start with a grammar
for the data file.

### Understanding the CD grammar

Here is the grammar that I have designed for parsing the CD data file.

	file: header body footer
	header: /.+/ date
	date: /\d\d?\s+\w+\s+\d{4}/
	body: col_heads /-+/ cd(s)
	col_heads: col_head(s)
	col_head: /\w+/
	cd: cd_line track_line(s)
	cd_line: /.{14}/ /.{19}/ /.{15}/ /\d{4}/
	track_line: '+' /.*/
	footer: /\d+/ 'CDs'

Let’s take a closer look at the individual rules. Like the parser,
we’ll take a top-down approach.

*  A data file is made up of three sections—a header, a body, and a footer.

*  The file header is made up of a string of any characters followed by a date.

*  A date is one or two digits followed by at least one space, any number of word characters, at least one space and four digits. Note that we are assuming that all dates will appear in the same format as the one in our sample file.

*  The file body contains the column headers followed by a number of characters and one or more CD records.

*  The column headers are made up of one or more headers per individual column.

*  A column header consists of a number of word characters.

*  A CD record consists of a CD line followed by at least one track record.

*  A CD line consists of a number of records, each of which is a particular number of characters long. We have to match in this way, as the CD record is in fixed width format.

*  A track record contains a + character followed by at least one other character.

*  A footer record consists of at least one digit followed by the text “CDs”.

### Testing the CD file grammar

Having defined our grammar, one of the best ways to test it is to
write a brief program like the one that we used to test the English
sentences. The program would look like this:

	use Parse::RecDescent;
	use vars qw(%datas @cols);
	my $grammar = q(
	file: header body footer
	header: /.+/ date
	date: /\d+\s+\w+\s+\d{4}/
	body: col_heads /-+/ cd(s)
	col_heads: col_head(s)
	col_head: /\w+/
	cd: cd_line track_line(s)
	cd_line: /.{14}/ /.{19}/ /.{15}/ /\d{4}/
	track_line: '+' /.+/ { $item[2] }
	footer: /\d+/ 'CDs'
	);
	$parser = Parse::RecDescent->new($grammar);
	my $text;
	{
	local $/ = undef;
	$text = <STDIN>;
	}
	print $parser->file($text) ? "valid" : "invalid";


This program will print valid or invalid depending on whether or not
the file passed to it on STDIN parses correctly against the given
grammar. In this case it does, but if it doesn’t and you want to find
out where the errors are, there are two useful variables which
Parse::RecDescent uses to help you follow what it is doing.

#### Debugging the grammar with $::RD\_TRACE and $::RD\_HINT

Setting $::RD\_TRACE to true will display a trace of the parsing
process as it progresses, allowing you to see where your grammar and
the structure of the file disagree. If the problems are earlier in the
process and there are syntax errors in your grammar, then setting
$::RD\_HINT to true will provide hints on how you could fix the
problems. Setting $::RD\_AUTOACTION to a snippet of code which prints
out the values in @item can also be a useful debugging tool.

### Adding parser actions

Having established that our grammar does what we want, we can proceed
with writing the rest of the program. As previously, most of the
interesting code is in the parser actions. Here is the complete
program:

	use strict;
	use Parse::RecDescent;
	use Data::Dumper;
	use vars qw(@cols);
	my $grammar = q(
	file: header body footer
	{
	my %rec =
	(%{$item[1]}, list => $item[2], %{$item[3]});
	\%rec;
	}
	header: /.+/ date
	{ { title => $item[1], date => $item[2] } }
	date: /\d+\s+\w+\s+\d{4}/ { $item[1] }
	body: col_heads /-+/ cd(s) { $item[3] }
	col_heads: col_head(s) { @::cols = @{$item[1]} }
	col_head: /\w+/ { $item[1] }
	cd: cd_line track_line(s)
	{ $item[1]->{tracks} = $item[2]; $item[1] }
	cd_line: /.{14}/ /.{19}/ /.{15}/ /\d{4}/
	{ my %rec; @rec{@::cols} = @item[1 .. $#item]; \%rec }
	track_line: '+' /.+/ { $item[2] }
	footer: /\d+/ 'CDs'
	{ { count => $item[1] } }
	);
	my $parser = Parse::RecDescent->new($grammar);
	my $text;
	{
	local $/ = undef;
	$text = <DATA>;
	}
	my $CDs = $parser->file($text);
	print Dumper($CDs);

As is generally the case, the parser actions will be easier to follow
if we examine them bottom up.

The footer rule returns a reference to a hash with only one value. The
key to this hash is count and the value is $item[1], which is the
number that is matched on the footer line. As we’ll see when we get to
the file rule, I chose to return this as a hash reference since it
makes it easier to combine parts into a data structure.

The track rule returns the name of the track.

The cd\_line rule builds a hash where the keys are the column headings
and the values are the associated values from the CD line in the file.
In order to do this, it makes use of the global @cols array which is
created by the col\_heads rule.

The cd rule takes the hash reference which is returned by the cd_line
rule and creates another element in the same hash where the key is
tracks, and the value is a reference to the array of multiple track
records which is returned by the track(s) subrule. The rule then
returns this hash reference.

The col_head rule matches one individual column heading and returns
that value.

The col\_heads rule takes the array which is returned by the
col\_head(s) subrule and assigns this array to the global array @cols,
so that it can later be used by the cd\_line rule.

The body rule returns the array returned by the cd(s) subrule. Each
element of this array is the hash returned by one occurrence of the cd
rule.

The date rule returns the date that was matched. The header rule works
similarly to the footer rule. It returns a reference to a two-element
hash. The keys in this hash are “title” and “date” and the values are
the respective pieces of matched text.

The file rule takes the three pieces of data returned by the header,
body, and footer rules and combines them into a single hash. It then
returns a reference to this hash.

#### Checking the output with Data::Dumper

The program uses the Data::Dumper module to print out a data dump of
the data structure that we have built. For our sample CD data file,
the output from this program look like this:

	$VAR1 = {
	'list' => [
	{
	'Released' => '1988',
	'Artist' => 'Bragg, Billy',
	'Title' => 'Workers\' Playtime',
	'Label' => 'Cooking Vinyl',
	'tracks' => [
	'She\'s Got A New Spell',
	'Must I Paint You A Picture'
	]
	},
	{
	'Released' => '1998',
	'Artist' => 'Bragg, Billy',
	'Title' => 'Mermaid Avenue',
	'Label' => 'EMI',
	'tracks' => [
	'Walt Whitman\'s Niece',
	'California Stars'
	]
	},
	{
	'Released' => '1993',
	'Artist' => 'Black, Mary',
	'Title' => 'The Holy Ground',
	'Label' => 'Grapevine',
	'tracks' => [
	'Summer Sent You',
	'Flesh And Blood'
	]
	},
	{
	'Released' => '1995',
	'Artist' => 'Black, Mary',
	'Title' => 'Circus',
	'Label' => 'Grapevine',
	'tracks' => [
	'The Circus',
	'In A Dream'
	]
	},
	{
	'Released' => '1971',
	'Artist' => 'Bowie, David',
	'Title' => 'Hunky Dory',
	'Label' => 'RCA',
	'tracks' => [
	'Changes',
	'Oh You Pretty Things'
	]
	},
	{
	'Released' => '1997',
	'Artist' => 'Bowie, David',
	'Title' => 'Earthling',
	'Label' => 'EMI',
	'tracks' => [
	'Little Wonder',
	'Looking For Satellites'
	]
	}
	],
	'title' => 'Dave\'s CD Collection',
	'count' => '6',
	'date' => '16 Sep 1999'
	};

You can see that this structure is the same as the one that we built
in chapter 8. The main part of the structure is a hash, the keys of
which are “list,” “title,” “count,” and “date.” Of these, all but
“list” is associated with a scalar containing data from the header or
the footer of the file. The key “list” is associated with a reference
to an array. Each element of that array contains the details of one CD
in a hash. This includes a reference to a further list that contains
the tracks from each CD.

Other features of Parse::RecDescent
-----------------------------------

That completes our detailed look at using Parse::RecDescent. It
should give you enough information to parse some rather complex file
formats into equally complex data structures. We have, however, only
scratched the surface of what Parse::RecDescent can do. Here is an
overview of some of its other features. For further details see the
documentation that comes with the module.

*  *Autotrees*—This is a method by which you can get the parser to automatically build a parse tree for your input data. If you don’t have a specific requirement for your output data structure, then this functionality might be of use to you.

*  *Lookahead rules*—Sometimes the data that you are parsing can be more complex than the examples that we have covered. In particular, if a token can change its meaning depending on what follows it, you should make use of lookahead rules. These allow you to specify text in the rule which must be matched, but is not consumed by the match. This is very similar to the (?= …) construct in Perl regular expressions.

*  *Error handling*—Parse::RecDescent has a powerful functionality to allow you to output error messages when a rule fails to match.

*  *Dynamic rules*—Because terminals are either text strings or regular expressions and both of these can contain variables which are evaluated at run time, it is possible to create rules which change their meaning as the parse progresses.

*  *Subrule argument*—It is possible for a rule to pass arguments down into its subrule and, therefore, alter the way that they work.

*  *Incremental parsing*—It is possible to change the definition of a grammar which a program is running, using two methods called Extend and Replace.

*  *Precompiling parsers*—Using the Precompile method it is possible to create a new module that will parse a particular grammar. This new module can then be used in programs without Parse::RecDescent being present.

Further information
-------

The best place to get more information about Parse::RecDescent is in
the manual pages that come with the module. Typing perldoc
Parse::RecDescent at any command line will show you this
documentation. The distribution also contains almost forty demo
programs and an HTML version of Damian Conway’s article for the
Winter 1998 issue of *The Perl Journal* titled “The man of descent,”
which is a useful introduction to parsing in general and
Parse::RecDescent in particular.

Summary
-------

*  Parse::RecDescent is a Perl module for building recursive descent parsers.

*  Parsers are created by passing the new method the definition of a grammar.

*  The parser is run by passing the text to be parsed to a method named after the top-level rule in the grammar.

*  Parser action code can be associated with grammar rules. The associated code is called when the rule matches.

*  The @item array contains details of the tokens which have matched in a given rule.

*  Parser actions can change the value that will be returned by a rule. This is how you can build up parse tree data structures.
