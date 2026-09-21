Appendix B: Essential Perl
==========================

Throughout this book I've assumed a working, if rudimentary, knowledge
of Perl. This appendix is a refresher of the "essential Perl" you need
in order to follow the code in the rest of the book — it isn't a
complete introduction to the language, and it moves considerably
faster than one would. If any of it feels genuinely new to you rather
than just a reminder, see the recommendations at the end of this
appendix before going any further.

Running Perl
------------

There are several ways to run a Perl script. Most commonly, you'll
save your code to a file and add a *shebang* line as the very first
line, naming the interpreter that should run it:

    #!/usr/bin/perl

(the exact path will vary from system to system — `which perl` will
tell you where yours lives). Many people give Perl files a `.pl`
extension, though it usually isn't necessary — except on Windows,
which decides how to run a file from its extension rather than its
shebang line, so there it's required. Having saved and (on
UNIX-like systems) made the file executable, you run it by typing its
name:

    ./cds.pl

or by calling the interpreter directly and handing it the script's
name:

    perl cds.pl

A handful of command-line options are worth knowing. `-c` checks a
script for syntax errors without running it — a useful first line of
defence before you commit code you haven't tested. `-d` runs the
script under Perl's built-in debugger. `-T` turns on taint mode, which
treats all input from outside your program as untrusted until you've
explicitly checked it; it's particularly worth knowing about if you
ever write a CGI script or anything else exposed to the outside world
(see `perldoc perlsec` for the details).

You'll also come across `-e`, which lets you pass Perl code directly
on the command line instead of putting it in a file:

    perl -e 'print "Hello World\n";'

On its own this looks like a toy, useful only for scripts too short to
bother saving — but combined with Perl's other command-line options it
becomes a genuinely useful tool for short, one-off jobs.
[Chapter 3](ch006.xhtml) covers this in detail, including the `-E`
option, which behaves like `-e` but also turns on every feature
available in your version of Perl — the same features discussed in
the next section.

Everything else you could want to know about running Perl is in the
perlrun manual page — type `perldoc perlrun` at your command line.

Installing modules from CPAN
----------------------------

Perl's standard library covers a lot of ground, but a great deal of
what makes Perl good for data munging lives outside it, on CPAN — the
Comprehensive Perl Archive Network. Nearly every module named in this
book, from `Text::CSV` to `DBI` to `Moo` to `XML::LibXML`, has to be
installed from there before you can use it.

The easiest way to do that today is with `cpanm` (short for
`App::cpanminus`), a small, dependency-free tool built specifically
for installing things from CPAN with the minimum of fuss. Your
system's own package manager will often have it (`apt install
cpanminus`, `brew install cpanminus`, and so on); failing that, you
can bootstrap it directly:

    curl -L https://cpanmin.us | perl - App::cpanminus

Once you have it, installing a module is a single command:

    cpanm Text::CSV

`cpanm` fetches the module, works out and installs whatever it
depends on, runs its test suite, and installs it — all without asking
you anything, in the normal case.

Perl also ships with its own built-in client, unimaginatively called
`cpan`, which does the same job but with a much more old-fashioned,
interactive interface. It's worth knowing it's there — every Perl
installation has it, with nothing extra to add — but `cpanm` is the
friendlier day-to-day tool, and the one assumed throughout this book
whenever it says "install X from CPAN."

If a project needs several CPAN modules, listing them in a `cpanfile`
lets you install the lot in one go (`cpanm --installdeps .`), which is
worth doing as soon as a project outgrows one or two dependencies — it
turns "what does this need to run?" from a question you answer by
reading the source into one you answer by reading a single file.

The modern baseline
-------------------

Every script in this book — and every serious Perl script you write
yourself — should start with three things:

    use strict;
    use warnings;
    use v5.36;

`use strict;` switches off a handful of pieces of "convenience"
behaviour that cause far more harm than good in practice. Its most
valuable effect is that it stops you from using a variable you haven't
first declared with `my`:

    $counnt++;         # typo for $count -- silently creates a new
                        # global variable without "strict"; a compile
                        # error with it

That single check catches an enormous number of typos before your
code ever runs. `use warnings;` asks Perl to tell you about other
dubious constructs — using a value before it's been given one,
comparing two strings numerically, and so on. In older code you may
see the command-line flag `-w` used for this instead; it does a
similar job, but `use warnings;` is generally preferred these days
because it's lexically scoped to the file it appears in, rather than
switching warnings on globally for every module your script happens
to load, including ones you didn't write and can't fix.

`use v5.36;` (or any later version) does something different again: it
declares which version of Perl your code expects, and as a side
effect turns on a whole bundle of features that are considered safe
and stable — including, as it happens, `strict` and `warnings`
themselves. Strictly speaking, then, a modern script only needs the
one line:

    use v5.36;

This book spells out all three anyway, partly for clarity to readers
still working with older Perls, and partly because plenty of code
you'll meet in the wild still does the same — but from here on,
whenever you see `use v5.36;` (or later) at the top of a script, you
can take `strict` and `warnings` as already switched on.

Version declarations enable other features too, on a rolling basis as
each one is judged ready. Two used throughout this book are `say` — a
version of `print` that adds the trailing newline for you — and
subroutine signatures, which let you declare a subroutine's parameters
directly in its definition rather than unpacking them by hand:

    use v5.36;

    say "Hello, World!";      # same as: print "Hello, World!\n";

[Chapter 3](ch006.xhtml) covers this mechanism in full, including how
to turn on individual features one at a time with `use feature`
instead of jumping to a particular Perl version all at once, and
exactly which version you need for signatures specifically.

Variables and data types
------------------------

Perl has three main kinds of variable — scalars, arrays, and hashes —
and, unlike languages such as C or Java, doesn't require you to
declare what *type* of data (number, string, and so on) a variable
will hold. What kind of variable you're working with is instead shown
by the symbol, or *sigil*, in front of its name: scalars use `$`,
arrays use `@`, and hashes use `%`. Every variable should be declared
with `my` the first time you use it — `use strict;` insists on it, and
it's good practice even when nothing's forcing you.

### Scalars

A scalar variable holds a single item of data — a number, a string,
or (as we'll see later) a reference to something bigger.

    my $artist = 'Bragg, Billy';
    my $year   = 1988;

Perl doesn't ask you to decide in advance whether a scalar holds a
number or a string; it works out what you mean from how you use it.
The same variable can hold either, and Perl will convert between them
as needed:

    my $count   = 3;
    my $message = "There are $count CDs by $artist";

    my $price      = '9.99';
    my $with_tax   = $price * 1.2;   # numeric context: '9.99' is
                                      # treated as the number 9.99

Double-quoted strings, as `$message` shows, interpolate variables
directly into the text. Single-quoted strings don't:

    my $literal = 'The value of $count is not shown here';

Double quotes also understand a handful of backslash escapes — `\n`
for a newline, `\t` for a tab, `\x1F` for the character with that hex
code, and so on. The full set is in `perldoc perldata`.

### Arrays

An array holds an ordered list of scalar values, and is prefixed with
`@`:

    my @artists = ('Bragg, Billy', 'Black, Mary', 'Bowie, David');

Access an individual element with a `$` sigil and a numeric index
starting from zero — a single element of an array is a scalar value,
not an array, which is why the sigil changes:

    my $first = $artists[0];    # 'Bragg, Billy'
    my $last  = $artists[-1];   # 'Bowie, David' -- negative indices
                                 # count back from the end

If you assign to an index beyond the current end of the array, Perl
extends it for you, filling any gap with `undef`:

    $artists[10] = 'Black, Mary';   # elements 3 .. 9 now exist and
                                     # are undef

A *slice* pulls out several elements at once. Because the result is
itself a list, it keeps the `@` sigil even though you're using square
brackets:

    my @first_two = @artists[0, 1];
    my @by_range  = @artists[0 .. 2];

Be careful when combining arrays — Perl flattens them into a single
list rather than nesting one inside the other:

    my @hobbits = ('Bilbo', 'Frodo');
    my @elves   = ('Elrond', 'Galadriel');
    my @all     = (@hobbits, @elves);   # four elements, not two

This is worth remembering, because it's also what happens to arguments
passed into a subroutine, as we'll see shortly.

Perl gives you functions for adding and removing elements at either
end of an array: `push @array, list` and `pop @array` work on the
end; `unshift @array, list` and `shift @array` work on the start.
`splice @array, $offset, $length, list` is the general-purpose tool
underneath all four — it removes `$length` elements starting at
`$offset` and replaces them with `list` (omit `list` to just delete;
omit `$length` to remove everything from `$offset` to the end).

`map` and `grep` are the two functions you'll reach for constantly
when munging data held in arrays. Suppose `@cds` holds one hash
reference per CD — we'll see exactly how structures like this are
built in the "References and data structures" section below:

    my @cds = (
      { artist => 'Bragg, Billy', title => "Workers' Playtime",
        label  => 'Cooking Vinyl', year => 1988 },
      { artist => 'Black, Mary',  title => 'Circus',
        label  => 'Grapevine',    year => 1995 },
      { artist => 'Bowie, David', title => 'Earthling',
        label  => 'EMI',          year => 1997 },
    );

`map` runs a block of code once for each element of a list (available
inside the block as `$_`) and returns the list of results:

    my @years = map { $_->{year} } @cds;   # (1988, 1995, 1997)

`grep` runs a block for each element too, but returns only the
elements for which the block was true, rather than transforming them:

    my @nineties = grep { $_->{year} >= 1990 } @cds;

One gotcha that catches a lot of newcomers out: assigning an *array*
to a scalar gives you its length, but assigning a *list* to a scalar
gives you the last element of that list — these look similar but
aren't the same operation at all:

    my $count    = @artists;              # length of @artists
    my $last_one = ('Bilbo', 'Frodo');    # 'Frodo', not 2

You can also find the index of an array's last element directly, with
`$#array` (in the example above, that would be `$#artists`).

### Hashes

A hash — sometimes still called an *associative array* in older
material — maps string keys to scalar values, and is prefixed with
`%`:

    my %label_for = (
      'Bragg, Billy' => 'Cooking Vinyl',
      'Black, Mary'  => 'Grapevine',
      'Bowie, David' => 'EMI',
    );

The `=>` ("fat comma") is really just a comma with better manners —
functionally identical, but it also auto-quotes the bareword to its
left, which is why the keys above don't need their own quotes.

Access (or set) an individual value with a `$` sigil and curly braces:

    my $label = $label_for{'Bragg, Billy'};
    $label_for{'Some New Artist'} = 'Some Label';

`keys %hash` and `values %hash` return a hash's keys and values as two
separate lists — in the same order as each other, though not
necessarily the order you added them in:

    foreach my $artist (keys %label_for) {
      print "$artist is on $label_for{$artist}\n";
    }

A *hash slice* accesses several values at once. As with an array
slice, the result is a list, so it takes the `@` sigil even though
you're indexing into a `%` variable with curly braces:

    my @some_labels = @label_for{'Bragg, Billy', 'Black, Mary'};

You'll build hashes like this constantly when summarizing data.
[Chapter 2](ch005.xhtml)'s `count_cds_by_attr` routine is a good
example: it builds a hash keyed by whichever field you're counting —
artist, year, whatever's passed in — incrementing the count each time
it sees a matching record. You can build the same kind of thing in one
line with `map`, too:

    my %title_for = map { $_->{artist} => $_->{title} } @cds;

Note that a hash and a scalar (or an array) can share the same name
without clashing — `%label_for` and any `$label_for` or `@label_for`
you might also have are three entirely separate variables, since it's
the sigil, not the name, that Perl uses to tell them apart. That
doesn't mean it's a good idea, though — reusing a name like this in
real code is a reliable way to confuse whoever reads it next
(quite possibly you, in six months), and is worth avoiding even though
Perl itself won't stop you.

### Scope: `my`, `our`, and `local`

Every example so far has declared its variables with `my`, which
creates a *lexical* variable — one that exists, and is visible, only
within the block (or file) where it's declared. This is what you want
almost all of the time, and it's what `use strict;` requires.

Occasionally you'll need a *package* variable instead: one that
belongs to an entire package rather than a particular block, and can
be referred to from outside it (by its full name, `$Package::name`, or
after importing it). These are declared with `our`, and you'll most
often meet them in module code, setting up inheritance or exports:

    package Customer_Rules;

    our @ISA    = qw(Exporter);
    our @EXPORT = qw(get_next_cust_no save_cust_record);

[Chapter 2](ch005.xhtml) uses exactly this pattern.

A third keyword, `local`, looks similar to `my` but does something
different again: it temporarily replaces the value of an *existing*
global variable for the rest of the current block, automatically
restoring the original value once the block ends. It's mostly there
for adjusting one of Perl's own special variables — `$/`, the input
record separator, is a common one — for a limited scope, and comes up
far less often in everyday code than either `my` or `our`. `perldoc
perlsub` has the full rules for all three.

Operators
---------

Perl has the usual set of mathematical operators — `+`, `-`, `*`, `/`,
`%` for modulus, and `**` for exponentiation — each with a
corresponding assignment form (`+=`, `-=`, and so on), plus `++` and
`--` for incrementing and decrementing. It also has bitwise operators
(`&`, `|`, `^`, `~`, `<<`, `>>`) for working directly on the binary
representation of a number, which come up occasionally when handling
binary data (see [Chapter 7](ch011.xhtml)).

Two operators are specific to strings: `.` concatenates two strings
together, and `x` repeats one — `'la' . 'la'` gives `'lala'`, while
`'la' x 3` gives `'lalala'`. In list context, `x` repeats a whole list
instead: `(0) x 5` gives a five-element list of zeroes, handy for
initializing a data structure.

Comparison operators come in two flavours, because Perl doesn't know
in advance whether your scalars hold numbers or strings: `<`, `<=`,
`==`, `!=`, `>=`, and `>` compare numerically, while `lt`, `le`, `eq`,
`ne`, `ge`, and `gt` compare as strings. Using the wrong flavour is an
easy mistake to make and `use warnings;` will usually catch it for
you. `<=>` and `cmp` are their sorting cousins — the numeric and
string "spaceship" operators — each returning -1, 0, or 1 depending on
whether the first operand is less than, equal to, or greater than the
second; [Chapter 3](ch006.xhtml) puts these to work when discussing
custom sort routines.

For combining conditions, `&&` and `||` are the ones you'll reach for
most, and both are *short-circuiting* — the right-hand side is only
evaluated if it's actually needed to determine the overall result.
That's the basis of a very common Perl idiom:

    open(my $fh, '<', 'cds.txt') or die "Can't open cds.txt: $!";

If `open` succeeds, its return value is true, which is already enough
to make the whole `or` expression true, so `die` never runs and never
needs to. `and` and `or` do the same jobs as `&&` and `||` but at much
lower precedence, which occasionally matters if you leave the
parentheses off a function call. Compare:

    open my $fh, '<', 'cds.txt' or die "Can't open cds.txt: $!";
    open my $fh, '<', 'cds.txt' || die "Can't open cds.txt: $!";

The first works exactly as intended — the low precedence of `or` means
Perl parses it as `(open my $fh, '<', 'cds.txt') or die ...`, so if
`open` fails, `die` fires. The second doesn't: `||` binds more tightly
than the comma that separates `open`'s own arguments, so Perl instead
parses it as `open my $fh, '<', ('cds.txt' || die ...)` — meaning
`die` only fires if the *filename* is false, not if `open` itself
fails. Since a non-empty filename is always true, that `die` branch is
effectively dead code, and a failed `open` passes completely
unnoticed, which is far worse than a script that merely looks wrong.
Once you add the parentheses back, as in the very first example above,
this stops mattering — which is exactly why the low-precedence `or`
idiom is usually written without them. Otherwise, the choice between
`&&`/`||` and `and`/`or` is mostly a matter of house style.

(You may also come across older code that opens a file with a
bareword filehandle instead of a scalar variable —
`open(DATA, 'cds.txt') or die ...;` — and without the three-argument
form shown above. Both still work, but the modern style, with a
lexical filehandle and an explicit mode, is safer and more flexible,
and is what's used throughout this book.)

Perl also has a defined-or operator, `//`, and its assignment form
`//=`. Where `||` asks "is this true?", `//` asks the narrower
question "is this *defined*?" — a distinction that matters a great
deal once your data might legitimately contain a zero or an empty
string, both of which are false but perfectly good values that `||`
would otherwise discard:

    my $year = $cd->{year} // 'unknown';   # 'unknown' only if year is
                                            # undef, not if it's 0

    $cust->{cust_no} //= get_next_cust_no();

You'll see `//=` used exactly like that — filling in a value only if
one isn't already present — in [Chapter 2](ch005.xhtml)'s
customer-record code, and again when we look at caching exchange rates
in [Chapter 6](ch010.xhtml).

Finally, the ternary operator (`?:`) picks between two values based on
a condition, and is often the tidiest way to write a short `if`/`else`:

    my $plural = $count == 1 ? 'CD' : 'CDs';

which does the same job as a four-line `if`/`else` block whose only
purpose is choosing between `'CD'` and `'CDs'`.

Flow of control
---------------

`if` executes a block only when its condition is true, and can be
extended with `elsif` and `else`:

    if ($cd->{year} < 1990) {
      print "$cd->{title} is from the 80s\n";
    } elsif ($cd->{year} < 2000) {
      print "$cd->{title} is from the 90s\n";
    } else {
      print "$cd->{title} is from $cd->{year}\n";
    }

`unless` is `if`'s mirror image — it runs its block when the condition
is *false*. Both `if` and `unless` can also be used as *statement
modifiers*, tacked onto the end of a simple statement, which often
reads more naturally than wrapping the statement in braces:

    print "$cd->{title}\n" unless $seen{$cd->{title}}++;
    $count++ if $cd->{year} >= 1990;

Perl has three looping constructs. The C-style `for` loop exists —

    for (my $x = 1; $x <= 10; ++$x) {
      print "$x squared is ", $x * $x, "\n";
    }

— but you'll rarely need it in practice, because `foreach` (Perl also
accepts plain `for` as a synonym) is both more common and more
flexible for working through a list:

    foreach my $cd (@cds) {
      print "$cd->{artist}: $cd->{title}\n";
    }

Omit the loop variable and each element becomes available as `$_`
instead, which is especially handy inside a short block:

    foreach (@cds) {
      print "$_->{artist}: $_->{title}\n";
    }

`while` loops for as long as its condition remains true — a common use
is reading a file a line at a time:

    while (my $line = <$fh>) {
      chomp $line;
      process($line);
    }

Three keywords let you adjust a loop's normal behaviour. `next`
immediately moves on to the next iteration, re-testing the loop's
condition first:

    foreach my $cd (@cds) {
      next unless $cd->{year};   # skip records with no year
      process($cd);
    }

`last` exits the loop altogether and continues with whatever comes
after it:

    foreach my $cd (@cds) {
      last if $cd->{year} < 0;   # stop at the first bit of bad data
      process($cd);
    }

and `redo` restarts the current iteration from the top, without
re-testing the loop's condition or moving on to the next element —
useful, for example, if you want to retry the same piece of input
after failing to validate it.

All three keywords act on the innermost enclosing loop by default. To
act on an outer loop instead, label it and name that label in your
`next`, `last`, or `redo`:

    ARTIST:
    foreach my $artist (keys %cds_by_artist) {
      foreach my $cd ($cds_by_artist{$artist}->@*) {
        next ARTIST if $cd->{year} < 1970;   # skip this artist entirely
        print "$artist: $cd->{title}\n";
      }
    }

Subroutines
-----------

Subroutines are defined with `sub`, with their parameters declared
directly in a *signature*:

    sub count_by_year($cds) {
      my %counts;
      $counts{$_->{year}}++ for $cds->@*;
      return \%counts;
    }

and called just like any built-in function:

    my $counts = count_by_year(\@cds);

Signatures are a comparatively recent addition to Perl —
[Chapter 3](ch006.xhtml) has the full story, including exactly which
version of Perl you need. In code written before signatures existed
(and you'll still see plenty of it, both elsewhere and occasionally in
this book, where it matters to the point being made), a subroutine's
arguments instead arrive in the special array `@_`, and are usually
unpacked by hand at the top of the subroutine:

    sub count_by_year {
      my ($cds) = @_;
      ...
    }

The two versions are equivalent — a signature is really just a tidier
way of writing exactly the same argument-unpacking Perl was always
doing anyway.

One thing to watch for either way: arrays and hashes passed as
arguments get flattened into one long list, the same as when combining
them directly (see "Arrays," above). A subroutine expecting an array
followed by a scalar,

    sub element {
      my (@arr, $x) = @_;   # doesn't work -- @arr greedily takes
      return $arr[$x];      # everything, leaving nothing for $x
    }

won't work as hoped, because the assignment to `@arr` doesn't know
where to stop pulling elements from `@_` and takes all of it, leaving
`$x` undefined. Putting the scalar first fixes this particular case —

    sub element {
      my ($x, @arr) = @_;
      return $arr[$x];
    }

— but the more general, and more common, solution used throughout this
book is to pass a *reference* to the array or hash instead of the
thing itself, since a reference is a single scalar value and so never
gets flattened. We'll come to references next.

A subroutine returns the value of its last statement, or you can use
`return` to hand back a value explicitly from anywhere inside it. That
return value can be a single scalar or a list, and the built-in
`wantarray` function tells you which kind of value the caller is
actually expecting, if you need a subroutine to behave differently in
each case. Full details of all of this are in `perldoc perlsub`.

References and data structures
------------------------------

A reference is a scalar value that points *at* another piece of data —
an array, a hash, another scalar, even a subroutine — rather than
containing that data directly. References are the mechanism behind
every complex data structure in Perl, and the reason is simple: an
array or a hash can only directly hold scalar values, but a reference
to an array, or to a hash, is itself just a scalar. So if you want an
array of arrays, or a hash containing other hashes, references are
how you get there.

Create a reference to an existing variable by putting a backslash in
front of it:

    my @cds     = ( ... );
    my $cds_ref = \@cds;

or build one directly, with no separately-named variable to reference
in the first place, using square or curly brackets:

    my $cds_ref = [ ... ];                          # anonymous array
    my $cd_ref  = { artist => 'Bragg, Billy', ... }; # anonymous hash

This second form is how you build a structure with more than one
level. An array of CD records, for instance — as used earlier in this
appendix, and throughout the book — is really an array where every
element is a reference to a hash:

    my @cds = (
      { artist => 'Bragg, Billy', title => "Workers' Playtime",
        year   => 1988 },
      { artist => 'Black, Mary',  title => 'Circus', year => 1995 },
    );

If you tried to build a similar structure without references — say,
grouping several CDs' worth of fields directly into one big array —
Perl would simply flatten everything into a single list, exactly as
described under "Arrays" above, and you'd lose the grouping
altogether. References are what let you sidestep that.

To get from a reference back to the thing it refers to, the modern
idiom is *postfix dereference*: write `->`, then the sigil of the kind
of thing you want, followed by an asterisk.

    my @all_cds  = $cds_ref->@*;    # the whole array
    my %all_data = $cd_ref->%*;     # the whole hash
    my $count    = $cds_ref->@*;    # in scalar context: a count,
                                     # exactly as for a plain array

Reaching *into* a nested structure — which is where references really
earn their keep — doesn't even need the asterisk. Just chain `->`
between however many levels of brackets or braces you need:

    foreach my $cd (@cds) {
      print "$cd->{artist}: $cd->{title} ($cd->{year})\n";
    }

    my %cds_by_year;
    push $cds_by_year{$cd->{year}}->@*, $cd for @cds;

    my @from_1988 = $cds_by_year{1988}->@*;
    my $first_1988_title = $cds_by_year{1988}[0]{title};

That last line demonstrates something worth knowing: Perl lets you
drop the arrow between two *consecutive* sets of brackets or braces —
`$cds_by_year{1988}[0]` and `$cds_by_year{1988}->[0]` mean exactly the
same thing — which is why deeply nested expressions like that one stay
readable instead of turning into a wall of arrows.

You'll also come across an older style of dereferencing in existing
code, which puts the sigil of the thing you want in front of either a
block or a plain reference variable: `@{$cds_ref}` and `@$cds_ref`
both mean the same as `$cds_ref->@*`, and `${$cds_by_year{1988}}[0]`
means the same as `$cds_by_year{1988}[0]`. Postfix dereference was
added in Perl 5.24, and you'll need to be able to recognize both
styles.

Which one reads better depends on what's being dereferenced. For a
plain reference sitting in its own variable, the two styles are about
equally clear — `@$cds_ref` and `$cds_ref->@*` say the same thing in
the same number of glances, and this book uses the older, shorter form
in that situation. The difference shows up once the reference isn't a
bare variable but an expression in its own right — a hash or array
element, the result of a method call, a chain of lookups. The old
style then forces you to wrap the whole expression in `@{ ... }` and
read it from the inside out:

    push @{ $cds_by_year{$cd->{year}} }, $cd for @cds;

whereas postfix dereference lets you read straight through,
left-to-right, with the dereference tacked on at the end where it
happens:

    push $cds_by_year{$cd->{year}}->@*, $cd for @cds;

That's the case this book reaches for `->@*`/`->%*`: not as a blanket
replacement for `@$ref`, but for the expressions old-style
dereferencing makes awkward to read.

References to subroutines work the same way, using `&` as their
sigil:

    my $formatter = \&count_by_year;
    my $counts    = $formatter->(\@cds);

and an *anonymous* subroutine — one with no name of its own — is
itself simply a reference, created directly with `sub`:

    my $formatter = sub ($cds) { ... };

Finally, the `ref` function tells you what kind of thing a reference
points at — `'ARRAY'`, `'HASH'`, `'CODE'`, and so on — which is
occasionally useful when you're not certain what you've been handed.

Full details of everything in this section are in `perldoc perlref`;
`perldoc perlreftut` is a gentler introduction if `perlref` moves too
fast, and `perldoc perldsc` is a cookbook of common data-structure
patterns, with plenty of worked examples of its own.

A nod to object orientation
---------------------------

Perl also supports object-oriented programming, though nothing above
requires it, and this book leans on OO only occasionally.
[Chapter 2](ch005.xhtml) has a full worked example built with
[Moo](https://metacpan.org/pod/Moo), currently the most common
lightweight way to write a Perl class, alongside a look at Perl's
newer built-in `class`/`method` syntax, which seems likely to take
over from Moo (and its heavier relative, Moose) as it matures. If
object orientation is new to you, that's the place to go for a proper
introduction rather than here.

Further reading
---------------

This appendix is a refresher, not a tutorial, and it's moved quickly
over a lot of ground. If any of it felt genuinely new rather than
familiar, [Chapter 1](ch004.xhtml) has recommendations for a fuller
introduction — *Learning Perl* (8th edition) by Randal Schwartz, brian
d foy, and Tom Phoenix (O'Reilly) remains the standard starting point,
and still the one I'd recommend first. Once the basics feel
comfortable, *Programming Perl* (4th edition) by Tom Christiansen,
brian d foy, Larry Wall, and Jon Orwant (also O'Reilly) is as close to
a definitive reference as Perl has.

Perl's own documentation is extensive, and installed alongside the
interpreter itself — `perldoc perl` gives you an index of everything
else that's available, and every manual page mentioned in this
appendix (`perldata`, `perlop`, `perlsub`, `perlref`, and the rest) is
sitting right there on your own machine. [Chapter 12](ch017.xhtml) has
more on where to find help and stay current with Perl generally.
