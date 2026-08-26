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
Regexp::Grammars, and in this chapter we take a detailed look at its
use.

Introduction to Regexp::Grammars
---------------------------------

[Regexp::Grammars](https://metacpan.org/pod/Regexp::Grammars) is a
powerful and expressive way to build recursive-descent parsers in
Perl, written by Damian Conway. Unlike Parse::RecDescent, which uses a
separate grammar language embedded in strings, Regexp::Grammars lets
you define your grammar directly inside a Perl regular expression.
This means you can write grammars that look and feel like Perl
regexes but are capable of parsing complex, nested structures.

Like Parse::RecDescent, it doesn't form a part of the standard Perl
distribution, so you will need to get it from the CPAN. It can be
found at
[https://metacpan.org/pod/Regexp::Grammars](https://metacpan.org/pod/Regexp::Grammars).
It comes with excellent documentation and plenty of examples that
demonstrate its capabilities.

Using Regexp::Grammars is fairly straightforward once you understand
the syntax. You define your grammar as a regular expression with
embedded rules, and then match your input text against it using
Perl's usual `=~` operator. If the match succeeds, Perl populates the
special `%/` hash with the entire parse tree—there's no separate step
where you build a parser object first.

All the examples in this chapter follow a basic structure that looks
something like this:

    use Regexp::Grammars;

    my $grammar = qr{
      <nocontext:>
      <top_rule>

      <rule: top_rule>
        # Your grammar goes here
    }x;

    my $text = q(
      # The text to be parsed
    );

    if ($text =~ $grammar) {
      # Access the parse tree through %/
      use Data::Dumper;
      print Dumper(\%/);
    } else {
      print "Parse failed\n";
    }

We'll explore this in more detail with practical examples, but the key
idea is that you can build full-featured parsers using just regex
syntax—no separate parsing engine required.

### Example: parsing simple English sentences

For example, if we go back to the example of simple English sentences
which we used in [Chapter 8](ch013.xhtml), we could write code like
this in order to check for valid sentences.

    use v5.40;

    use Regexp::Grammars;

    my $grammar = qr{
        <nocontext:>
        \A <Sentence> \Z

        <rule: Sentence>
            <Subject> <Verb> <Object>

        <rule: Subject>
            <NounPhrase>

        <rule: Object>
            <NounPhrase>

        <rule: Verb>
            wrote | likes | ate

        <rule: NounPhrase>
            <Pronoun> | <ProperNoun> | <Article> <Noun>

        <rule: Article>
            a | the | this

        <rule: Pronoun>
            it | he

        <rule: ProperNoun>
            Perl | Dave | Larry

        <rule: Noun>
            book | cat
    }x;

    while (<DATA>) {
        chomp(my $line = $_);
        print "'$line' is ";
        print 'NOT ' unless $line =~ $grammar;
        say "a valid sentence";
    }

    __DATA__
    Larry wrote Perl
    Larry wrote a book
    Dave likes Perl
    Dave likes the book
    Dave wrote this book
    the cat ate the book
    Dave got very angry

Notice that we have expanded the terminals to actually represent a
(very limited) subset of English words. Notice too the `use v5.40` at
the top of the script—recent versions of Perl bundle up a whole set of
modern features (including `strict`, `warnings`, `say`, and
subroutine signatures, which we'll use later in the chapter) behind a
single version declaration, so we don't need to enable them one at a
time.

The output of this script is as follows:

    'Larry wrote Perl' is a valid sentence
    'Larry wrote a book' is a valid sentence
    'Dave likes Perl' is a valid sentence
    'Dave likes the book' is a valid sentence
    'Dave wrote this book' is a valid sentence
    'the cat ate the book' is a valid sentence
    'Dave got very angry' is NOT a valid sentence

Which shows that "Dave got very angry" is the only text in our data,
which is not a valid sentence (by the rules of our
grammar of course—not by the real rules of English).

#### Explaining the code

The only complex part of this script is the definition of the grammar.
The syntax may look like a regular expression—and, in fact, it is
one—but with embedded rule definitions that extend what Perl regexes
are normally capable of.

Each rule is introduced with a `<rule: name>` block, and rules can
refer to each other by name using angle brackets (for example,
`<Subject>` or `<Verb>`). If you read each rule as saying "this is
made up of" and interpret the vertical bars (`|`) as "or," the
structure becomes quite readable.

In this example, all of the terminals—the bits of text that the
parser matches directly—are fixed strings. As we shall see later in
the chapter, it is quite possible to match Perl regular expressions
instead.

Having defined our grammar, we simply match a string against it using
Perl's usual `=~` operator. If the match succeeds, it means the input
matched the top-level rule—in our case, `Sentence`. The full parse
tree is then available in the special `%/` hash, which is populated
automatically by Regexp::Grammars. If the match fails, the input
doesn't conform to the grammar.

Returning parsed data
----------------------

The previous example is all very well if you just want to know
whether your data matches the rules defined by a grammar, but it
doesn't actually produce any useful data structures representing the
parsed content. To get that, we need to look a little deeper into how
Regexp::Grammars works.

Unlike Parse::RecDescent, you don't need to write any extra code to
get a data structure out of Regexp::Grammars. It builds a structured
parse tree automatically as part of the match, storing it in the
special `%/` hash. Each rule that successfully matches contributes to
this structure, with named subrules becoming nested hashes—and, as
we'll see shortly, repeated subrules becoming arrays.

By inspecting or walking through `%/`, you can extract detailed
information about what was matched and how it fits into the grammar,
without having to write any explicit parsing actions. Let's look at a
more substantial example to see how this works in practice.

### Example: parsing a Windows INI file

Let's look at parsing a Windows INI file. These files contain a
number of named sections. Each of these sections contain a number of
assignment statements. Figure 11.1 shows an example INI together with
the various parts that make up the file structure.

![INI File Structure](images/11-1-ini-file-structure.svg)

In this example we have sections called "files" and "rules." The
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

![INI file data structure](images/11-2-ini-file-data-structure.svg)

This means that you can get an individual value very easily using code
like:

    $input_file = $Config{files}{input};

As we'll see, the raw parse tree that Regexp::Grammars builds for us
doesn't *quite* look like this—but it's only a few lines of ordinary
Perl away from it.

### Understanding the INI file grammar

Let's take a look at a grammar that defines an INI file, this time
written using Regexp::Grammars.

    my $grammar = qr{
        \A <File> \Z

        <nocontext:>

        <rule: File>
            <[Section]>+

        <rule: Section>
            <Header> \s* \n
            <[Assign]>*

        <rule: Header>
            \[ <Name> \]

        <rule: Name>
            \w+

        <rule: Assign>
            \s* <Key> \s* = \s* <Value> \s* \n?

        <rule: Key>
            \w+

        <rule: Value>
            [^\n\r]+
    }x;

The grammar can be explained in English like this:

*  An INI file consists of one or more sections.

*  Each section consists of a header followed by zero or more assignments.

*  The header consists of a `[` character, a name, and a `]` character.

*  A name is a sequence of one or more word characters.

*  An assignment consists of a key, an `=` character, and a value, each surrounded by optional whitespace.

#### Repeating subrules and lists

There are a couple of new features to notice here. First, notice the
square brackets around `Section` and `Assign` in the `File` and
`Section` rules: `<[Section]>+` and `<[Assign]>*`. In Regexp::Grammars,
wrapping a subrule name in square brackets tells the module to collect
*every* match of that subrule into an array, rather than keeping only
the most recent one (which is what a plain `<Section>+` would do). The
quantifiers themselves work exactly as they do in any other Perl
regular expression: `+` means "one or more" and `*` means "zero or
more." You'll also see `?` for "optional" and the usual `{n,m}` style
counted repetition.

Regexp::Grammars also supports a separated-list syntax, `<[NAME]>+ %
SEPARATOR`, for the common case of repeated items separated by
something like a comma or a run of whitespace. We'll make use of that
later in the chapter.

#### Using regular expressions

The other thing to notice is that, because a Regexp::Grammars grammar
*is* a Perl regular expression, every terminal in it can be as simple
or as sophisticated as you like. Here we're using `\w+` to match a
name or a key, and a small negated character class, `[^\n\r]+`, to
match a value—anything up to the end of the line. There's no separate
mini-language to learn for this, the way there is with
Parse::RecDescent: it's the same regular expressions you already know.

From parse tree to data structure
------------------------------------

With Parse::RecDescent, extracting a useful data structure from a
successful parse meant attaching your own action code to each rule,
using the special `@item` array to see what had just been matched.
Regexp::Grammars does away with all of that: because it builds the
parse tree for you automatically, there's usually no action code to
write at all.

Here's a short program that parses an INI file and dumps the parse
tree that Regexp::Grammars builds for us:

    use Regexp::Grammars;
    use Data::Dumper;

    my $grammar = qr{
        \A <File> \Z

        <nocontext:>

        <rule: File>
            <[Section]>+

        <rule: Section>
            <Header> \s* \n
            <[Assign]>*

        <rule: Header>
            \[ <Name> \]

        <rule: Name>
            \w+

        <rule: Assign>
            \s* <Key> \s* = \s* <Value> \s* \n?

        <rule: Key>
            \w+

        <rule: Value>
            [^\n\r]+
    }x;

    local $/ = undef;
    my $text = <STDIN>;

    if ($text =~ $grammar) {
        print Dumper(\%/);
    } else {
        print "Parse failed.\n";
    }

Run against our sample INI file, this produces a tree that mirrors the
shape of the grammar: a `File` key holding an array of `Section`
hashes, each with a `Header` (itself holding a `Name`) and an array of
`Assign` hashes, each with a `Key` and a `Value`. Every rule name in
the grammar becomes a hash key in the result; every `<[...]>` subrule
becomes an array.

That's a completely faithful record of the parse, but it's a little
more deeply nested than the `$Config{files}{input}`-style structure we
said we wanted back at the start of this section. Getting from one to
the other is now just ordinary Perl—no more grammar-writing required:

    my $tree = \%/;
    my $output = {};

    for my $section ($tree->{File}{Section}->@*) {
        my $name = $section->{Header}{Name};
        my $assignments = $section->{Assign};
        $output->{$name} = {
            map { $_->{Key} => $_->{Value} } $assignments->@*
        };
    }

This walks the array of sections, and for each one builds a hash of
key/value pairs from its assignments, keyed by the section's name. The
result is exactly the hash of hashes we designed at the start: you can
now write `$output->{files}{input}` to get at an individual value.

Putting the whole thing together, and printing the result as JSON
instead of with Data::Dumper, gives us a complete, modern replacement
for the original Parse::RecDescent version:

    use v5.40;

    use Regexp::Grammars;
    use JSON::MaybeXS;

    my $grammar = qr{
        \A <File> \Z

        <nocontext:>

        <rule: File>
            <[Section]>+

        <rule: Section>
            <Header> \s* \n
            <[Assign]>*

        <rule: Header>
            \[ <Name> \]

        <rule: Name>
            \w+

        <rule: Assign>
            \s* <Key> \s* = \s* <Value> \s* \n?

        <rule: Key>
            \w+

        <rule: Value>
            [^\n\r]+
    }x;

    local $/ = undef;
    my $text = <STDIN>;

    if ($text =~ $grammar) {
        my $tree = \%/;
        my $output = {};

        for my $section ($tree->{File}{Section}->@*) {
            my $name = $section->{Header}{Name};
            my $assignments = $section->{Assign};
            $output->{$name} = {
                map { $_->{Key} => $_->{Value} } $assignments->@*
            };
        }

        say JSON->new->utf8->pretty->encode($output);
    } else {
        say "Parse failed.";
    }

Run against a sample INI file with `files` and `rules` sections, this
prints something like:

    {
       "files" : {
          "input" : "data_in",
          "output" : "data_out",
          "ext" : "dat"
       },
       "rules" : {
          "quote" : "double",
          "sep" : "comma",
          "spaces" : "trim"
       }
    }

Another example: the CD data file
-----------------------------------

Let's take a look at another example of parsing a data file, this time
using Regexp::Grammars. We'll take a look at how we'd parse the CD
data file that we discussed in [Chapter 8](ch013.xhtml). What follows
is the data file we were discussing:

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

In [Chapter 8](ch013.xhtml) we came up with a rather unsatisfying way
to extract the data from this file and put it into a data structure.
Now that Regexp::Grammars is in our toolkit, we should be able to come
up with something far more elegant.

As with the last example, the best approach is to start with a
grammar for the data file.

### Understanding the CD grammar

Here is the grammar that I have designed for parsing the CD data file.

    my $grammar = qr{
        \A
        <File>
        \Z

        <nocontext:>

        <rule: File>
            <Header>
            <Body>
            <Footer>

        <rule: Header>
            <Title> \n
            <Date> \n

        <rule: Title>
            [^\n]+

        <rule: Date>
            \d+\s+\w+\s+\d{4}

        <rule: Body>
            <ColHeads>
            <Divider>
            <[CD]>+

        <rule: ColHeads>
            <[ColName]>+ %\s+ \n

        <rule: ColName>
            \w+

        <rule: Divider>
            -+ \n

        <rule: CD>
            <CDLine>
            <[TrackLine]>*

        <rule: CDLine>
            <Artist> <TitleField> <Label> <Released> \n

        <rule: Artist>
            .{14}

        <rule: TitleField>
            .{19}

        <rule: Label>
            .{15}

        <rule: Released>
            \d{4}

        <rule: TrackLine>
            \+ <Track> \n

        <rule: Track>
            [^\n]+

        <rule: Footer>
            <Count> \s+ Records \n?

        <rule: Count>
            \d+
    }x;

Let's take a closer look at the individual rules, again taking a
top-down approach.

*  A data file (`File`) is made up of three sections—a header, a body, and a footer.

*  The `Header` is a `Title` line followed by a `Date` line.

*  The `Title` is any text up to the end of the line.

*  A `Date` is one or more digits followed by whitespace, one or more word characters, more whitespace, and four digits. As before, we're assuming that all dates appear in the same format as the one in our sample file.

*  The `Body` contains the column headings (`ColHeads`), a divider line, and one or more `CD` records.

*  `ColHeads` is one or more `ColName`s, separated by runs of whitespace—the `<[ColName]>+ %\s+` syntax is the separated-list form we mentioned earlier.

*  A `ColName` is a run of word characters.

*  A `Divider` is a run of dashes on a line by itself.

*  A `CD` record consists of a `CDLine` followed by zero or more `TrackLine`s.

*  A `CDLine` consists of four fixed-width fields—`Artist`, `TitleField`, `Label`, and `Released`—matched using `.{n}` rather than a word-based pattern, since the CD record is in fixed-width format.

*  A `TrackLine` is a `+` character followed by a `Track`—the rest of the line.

*  A `Footer` is a `Count`, some whitespace, and the literal text "Records".

Note that, unlike the fixed-width rules we saw in [Chapter 7](ch011.xhtml), we don't
need to calculate column offsets by hand here—we just describe the
width of each field and let the regex engine do the counting.

### Testing the CD file grammar

Having defined our grammar, one of the best ways to test it is to
write a brief program like the one we used to test the English
sentences:

    use Regexp::Grammars;

    my $grammar = qr{
        ... # as above
    }x;

    local $/ = undef;
    my $text = <STDIN>;

    print $text =~ $grammar ? "valid" : "invalid";

This program prints `valid` or `invalid` depending on whether or not
the file passed to it on `STDIN` matches the grammar. If it doesn't,
and you want to find out where things went wrong, Regexp::Grammars has
its own built-in debugger to help you.

#### Debugging the grammar with `<debug:...>`

Rather than the global variables that Parse::RecDescent uses
(`$::RD_TRACE` and `$::RD_HINT`), Regexp::Grammars is controlled with
a `<debug:...>` directive that you place directly inside the grammar.
Adding

    <debug: on>

near the top of a grammar turns on a step-by-step trace of the
matching process, showing you which rules are being tried and where
they succeed or fail—invaluable for working out where your grammar
and the structure of your file disagree. You can turn tracing off
again partway through a grammar with `<debug: off>`, which is useful
if you only want a detailed trace of one troublesome rule rather than
the whole grammar.

### Adding parser actions

As we saw with the INI file example, Regexp::Grammars builds the
parse tree for us automatically, so there's no need for the kind of
per-rule action code that Parse::RecDescent requires. Here is the
complete program for parsing the CD file, including the code that
turns the raw parse tree into a tidier data structure:

    use strict;
    use warnings;

    use builtin qw(trim);
    no warnings 'experimental::builtin';

    use Regexp::Grammars;
    use Data::Dumper;

    my $grammar = qr{
        \A
        <File>
        \Z

        <nocontext:>

        <rule: File>
            <Header>
            <Body>
            <Footer>

        <rule: Header>
            <Title> \n
            <Date> \n

        <rule: Title>
            [^\n]+

        <rule: Date>
            \d+\s+\w+\s+\d{4}

        <rule: Body>
            <ColHeads>
            <Divider>
            <[CD]>+

        <rule: ColHeads>
            <[ColName]>+ %\s+ \n

        <rule: ColName>
            \w+

        <rule: Divider>
            -+ \n

        <rule: CD>
            <CDLine>
            <[TrackLine]>*

        <rule: CDLine>
            <Artist> <TitleField> <Label> <Released> \n

        <rule: Artist>
            .{14}

        <rule: TitleField>
            .{19}

        <rule: Label>
            .{15}

        <rule: Released>
            \d{4}

        <rule: TrackLine>
            \+ <Track> \n

        <rule: Track>
            [^\n]+

        <rule: Footer>
            <Count> \s+ Records \n?

        <rule: Count>
            \d+
    }x;

    local $/ = undef;
    my $text = <DATA>;

    if ($text =~ $grammar) {
        my $data = \%/;

        my %output = (
            title => $data->{File}{Header}{Title},
            date  => $data->{File}{Header}{Date},
            count => $data->{File}{Footer}{Count},
            list  => [],
        );

        for my $cd (@{ $data->{File}{Body}{CD} }) {
            push @{ $output{list} }, {
                artist   => trim($cd->{CDLine}{Artist}),
                title    => trim($cd->{CDLine}{TitleField}),
                label    => trim($cd->{CDLine}{Label}),
                released => $cd->{CDLine}{Released},
                tracks   => [ map { $_->{Track} } @{ $cd->{TrackLine} || [] } ],
            };
        }

        print Dumper(\%output);
    } else {
        print "Parse failed\n";
    }

    __DATA__
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

Working through this bottom up: `$data->{File}{Body}{CD}` is the array
of CD records built for us by the `<[CD]>+` subrule. For each one, we
build a small hash with the artist, title, label, and release year
taken straight from the fixed-width fields, and a list of track names
taken from its `TrackLine` array (if there is one—the `|| []` guards
against a CD with no listed tracks). The `title`, `date`, and `count`
come straight from the corresponding parts of the tree.

Notice the calls to `trim`, from Perl's `builtin` namespace: because
the artist, title, and label fields are fixed-width, the text
Regexp::Grammars hands us still has the padding spaces attached, and
`trim` strips them off. This is a good example of a small but genuine
win from writing this code today rather than twenty-five years ago—the
original Parse::RecDescent version of this program left that padding
in the data, and you'd only have noticed it if you'd looked closely at
its `Data::Dumper` output.

#### Checking the output with Data::Dumper

For our sample CD data file, the output from this program looks like
this:

    $VAR1 = {
             'list' => [
                        {
                          'released' => '1988',
                          'artist' => 'Bragg, Billy',
                          'title' => 'Workers\' Playtime',
                          'label' => 'Cooking Vinyl',
                          'tracks' => [
                                        'She\'s Got A New Spell',
                                        'Must I Paint You A Picture'
                                      ]
                        },
                        {
                        'released' => '1998',
                        'artist' => 'Bragg, Billy',
                        'title' => 'Mermaid Avenue',
                        'label' => 'EMI',
                        'tracks' => [
                                      'Walt Whitman\'s Niece',
                                      'California Stars'
                                    ]
                        },
                        {
                        'released' => '1993',
                        'artist' => 'Black, Mary',
                        'title' => 'The Holy Ground',
                        'label' => 'Grapevine',
                        'tracks' => [
                                      'Summer Sent You',
                                      'Flesh And Blood'
                                    ]
                        },
                        {
                        'released' => '1995',
                        'artist' => 'Black, Mary',
                        'title' => 'Circus',
                        'label' => 'Grapevine',
                        'tracks' => [
                                      'The Circus',
                                      'In A Dream'
                                    ]
                        },
                        {
                        'released' => '1971',
                        'artist' => 'Bowie, David',
                        'title' => 'Hunky Dory',
                        'label' => 'RCA',
                        'tracks' => [
                                      'Changes',
                                      'Oh You Pretty Things'
                                    ]
                        },
                        {
                        'released' => '1997',
                        'artist' => 'Bowie, David',
                        'title' => 'Earthling',
                        'label' => 'EMI',
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

This is the same structure we built with Parse::RecDescent earlier in
the chapter (give or take the trimmed whitespace), which is worth
pausing on: the grammar-writing effort has moved almost entirely into
*describing the shape of the data*, and almost out of *writing code to
extract it*.

If you'd rather have this as JSON—handy if you're feeding it to
another program or a web page rather than to a Perl script—swap the
`Data::Dumper` call for `JSON::MaybeXS`, and pull the per-CD
hash-building out into a small subroutine using subroutine signatures:

    use v5.40;
    use builtin qw(trim);
    no warnings 'experimental::builtin';

    use Regexp::Grammars;
    use JSON::MaybeXS;

    my $grammar = qr{ ... }x;   # as above

    local $/ = undef;
    my $text = <DATA>;

    if ($text =~ $grammar) {
        my $data = \%/;

        my $output = {
            title => $data->{File}{Header}{Title},
            date  => $data->{File}{Header}{Date},
            count => $data->{File}{Footer}{Count},
            list  => [ map { cd_record($_) } $data->{File}{Body}{CD}->@* ],
        };

        say JSON->new->utf8->pretty->encode($output);
    } else {
        say "Parse failed";
    }

    sub cd_record ($cd) {
        return {
            artist   => trim($cd->{CDLine}{Artist}),
            title    => trim($cd->{CDLine}{TitleField}),
            label    => trim($cd->{CDLine}{Label}),
            released => $cd->{CDLine}{Released},
            tracks   => [ map { $_->{Track} } $cd->{TrackLine}->@* ],
        };
    }

    __DATA__
    ... # as above

We'll be looking at JSON in much more detail in the next chapter.

Other features of Regexp::Grammars
------------------------------------

That completes our detailed look at using Regexp::Grammars. It should
give you enough information to parse some rather complex file formats
into equally complex data structures. We have, however, only
scratched the surface of what Regexp::Grammars can do. Here is an
overview of some of its other features. For further details see the
documentation that comes with the module.

*  *Tokens vs. rules*—Every rule we've defined in this chapter has used `<rule: name>`, which automatically skips whitespace between subrules. If you need precise control over whitespace instead (for example, when parsing something whitespace-sensitive), you can define a `<token: name>` instead, which behaves like an ordinary Perl regex with no automatic whitespace skipping.

*  *Semantic predicates*—The `<require: (?{ CODE })>` directive lets you fail a match based on arbitrary Perl code, not just on what the text looks like—useful for things like checking that a value falls within an expected range.

*  *Custom error messages*—The `<error:...>` and `<fatal:...>` directives let you queue up a helpful error message when part of a grammar fails to match, rather than leaving the caller to guess why the whole match failed.

*  *Blessing results into objects*—The `<objrule:...>` and `<objtoken:...>` directives let you have Regexp::Grammars bless the hash it builds for a rule into a class of your choosing, so a successful parse can hand you back real objects instead of plain hashes.

*  *Named, reusable grammars*—The `<grammar:...>` and `<extends:...>` directives let you define a grammar once and reuse or extend it from other grammars, which is handy if you're parsing several related formats.

*  *Free lookahead and backreferences*—Because a Regexp::Grammars grammar is a real Perl regular expression under the hood, all of the usual regex tools—lookahead, lookbehind, backreferences, and so on—are available to you directly, without needing special support from the module.

Further information
-------

The best place to get more information about Regexp::Grammars is in
the manual page that comes with the module. Typing `perldoc
Regexp::Grammars` at any command line will show you this
documentation, including a substantial cookbook of worked examples.

Summary
-------

*  Regexp::Grammars is a Perl module for building recursive descent parsers, using ordinary Perl regular expressions extended with named rules.

*  Grammars are defined as a `qr{}` pattern, using `<rule: name>` (or `<token: name>`) to introduce each named subrule.

*  A grammar is matched against text using Perl's usual `=~` operator.

*  On a successful match, Regexp::Grammars automatically builds a parse tree and makes it available in the special `%/` hash—there's no need to write parser actions to extract a data structure.

*  Wrapping a subrule name in square brackets, as in `<[Name]>`, collects every match of that subrule into an array rather than keeping only the last one.

*  Turning the raw parse tree into a shape that suits your program is usually just a few lines of ordinary Perl.
