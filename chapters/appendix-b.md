Appendix B: Essential Perl
==========================

Throughout this book I have assumed that you have a certain level of
knowledge of Perl and have tried to explain everything that I have
used beyond that level. In this appendix, I’ll give a brief overview
of the level of Perl that I’ve been aiming at. Note that this is not
intended to be a complete introduction to Perl. For that you would be
better looking at *Learning Perl* by Randal Schwartz and Tom
Christiansen (O’Reilly); *Elements of Programming with Perl* by
Andrew Johnson (Manning), or *Perl: The Programmer’s Companion* by
Nigel Chapman (Wiley).

Running Perl
------------

There are a number of ways to achieve most things in Perl and running
Perl scripts is no exception. In most cases you will write your Perl
code using a text editor and save it to a file. Many people like to
give Perl program files the extension .pl, but this usually isn’t
necessary. !!! FOOTNOTE  1 I say “usually” because Windows uses the
extension of the file to determine how to run it. Therefore, if
you’re developing Perl under Windows, you’ll need the .pl extension.
!!!

Under most modern operating systems the command interpreter works out
how to run a script by parsing the first line of the script. If the
first line looks like

	#!/path/to/script/interpreter

then the program defined in this line will be called and your program
file will be passed to it as input. In the case of Perl, this means
that your Perl program files should usually start with the line

	#!/usr/bin/perl

(although the exact path to the Perl interpreter will vary from system
to system). Having saved your program (and made the file executable if
your operating system requires it) you can run it by typing the name
of the file on your command line; e.g., if your script is in a file
called myscript.pl you can run it by typing

	myscript.pl

at the command line.

An alternative would be to call the Perl interpreter directly, passing
it the name of your script like this:

	perl myscript.pl

There are a number of command line options that you can either put on
the command line or on the interpreter line in the program file. The
most useful include:

* -w Asks Perl to notify you when it comes across a number of unsafe programming practices in your program. These include using a variable before it is initialized and attempting to write to a file handle that is opened for reading. These warnings are usually very useful and there is no good reason not to use this option for every Perl program that you write.

* -T Turns on Perl’s “taint” mode. In this mode all input from an external source is untrusted by default. You can make use of such input only by explicitly cleaning it first. This is particularly useful if you are writing a CGI script. For more details see the perlsec manual page.

* -c Checks a script for syntax errors without executing it.

* -d Runs the script using Perl’s built-in debugger.

There is another way that you can pass Perl code to the Perl
interpreter. This is to use the -e command line option. A text string
following this option is assumed to be code to be executed, for
example:

	perl -e 'print "Hello World\n";'

will print the string “Hello World” to the console.

It may seem that this feature wouldn’t be very useful as the only
scripts that you can write like this would be very small; however,
Perl has a number of other command line options that can combine
with -e to create surprisingly complex scripts. Details of these
options are given in [Chapter 3](/chapter3.html).

All of the information that you could ever need about running Perl can
be found in the perlrun manual page.

Variables and data types
------------------------

Perl supports a number of different data types. Each data type can be
stored in its own type of variable. Unlike languages such as C or
Pascal, Perl variables are not strongly typed. This means that a
variable that contains a number can just as easily be used as a string
without having to carry out any conversions.

The main data types that you will come across in Perl are scalars,
arrays, and hashes. More complex data structures can be built using a
combination of these types. The type of a Perl variable can be
determined by the symbol that precedes the variable name. Scalars use
$, arrays use @, and hashes use %.

### Scalars

A scalar variable holds a single item of data. This data can be either
a number or a string (or a reference, but we’ll come to that later).
Here are some examples of assigning values to a scalar variable:

	$text = 'Hello World';
	$count = 100;
	$count = 'one hundred';

As you can see from the last two examples, the same scalar variable
can contain both text and numbers. If a variable holds a number and
you use it in a context where text is more useful, then Perl
automatically makes the translation for you.

	$number = 1;
	$text = "$number ring to rule them all";

After running this code, $text would contain the string “1 ring to
rule them all”. This also works the other way around. !!! FOOTNOTE  2
You can always turn a number into a string, but it’s harder to turn
most strings into numbers. !!!

	$number = '100';
	$big_number = $number * 2; # $big_number now contains the value 200.

Notice that we have used two different types of quotes to delimit
strings in the previous examples. If a string is in double quotes and
it contains variable names, then these variables are replaced by
their values in the final string. If the string is in single quotes
then variable expansion does not take place. There are also a number
of character sequences which are expanded to special characters
within double quotes. These include \n for a newline character, \t
for a tab, and \x1F for a character whose ASCII code is 1F in hex.
The full set of these escape sequences is in perldoc perldata.

### Arrays

An array contains an ordered list of scalar values. Once again the
scalar values can be of any type. Here are some examples of array
assignment:

	@empty = ();
	@hobbits = ('Bilbo', 'Frodo', 'Merry');
	@elves = ('Elrond', 'Legolas', 'Galadriel');
	@people = (@hobbits, @elves);
	($council, $fellow, $mirror) = @elves;

Notice that when assigning two arrays to a third (as in the fourth
example above) the result array is an array consisting of six
elements, not an array with two elements each of which is another
array. Remember that the elements of an array can only be scalars. The
final example shows how you can use list assignment to extract data
from an array. You can access the individual elements of an array
using syntax like this:

	$array[0]

You can use this syntax to both get and set the value of an individual
array element.

	$hero = $hobbits[0];
	$hobbits[2] = 'Pippin';

Notice that we use $ rather than @ to denote this value. This is
because a single element of an array is a scalar value, not an array
value.

If you assign a value to an element outside the current array index
range, then the array is automatically extended.

	$hobbits[3] = 'Merry';
	$hobbits[100] = 'Sam';

In that last example, all of the elements between 4 and 99 also
magically sprang into existence, and they all contain the value undef.

You can use negative index values to access array values from the end
of the array.

	$gardener = $hobbits[-1]; # $gardener now contains 'Sam'

You can use an *array slice* to access a number of elements of an
array at once. In this case the result is another array.

	@ring_holders = @hobbits[0, 1];

You can also use syntax indicating a range of values:

	@ring_holders = @hobbits[0 .. 1];

or even another array which contains the indexes of the values that you
need.

	@index = (0, 1);
	@ring_holders = @hobbits[@index];

You can combine different types of values within the same assignment.

	@ring_holders = ('Smeagol', @hobbits[0, 1], 'Sam');

If you assign an array to a scalar value, you will get the number of
elements in the array.

	$count = @ring_holders;  # $count is now 4

There is a subtle difference between an array and a *list* (which is
the set of values that an array contains). Notably, assigning a list
to a scalar will give you the value of the rightmost element in the
list. This often confuses newcomers to Perl.

	$count = @ring_holders;  # As before, $count is 4
	$last = ('Bilbo', 'Frodo'); # $last contains 'Frodo'

You can also get the index of the last element of an array using the
syntax:

	$#array

There are a number of functions that can be used to process a list.

* push @array, list—Adds the elements of list to the end of @array.

* pop @array—Removes and returns the last element of @array.

* shift @array—Removes and returns the first element of @array.

* unshift @array, list—Adds the elements of list to the front of @array.

* splice @array, $offset, $length, list—Removes and returns $length elements from @array starting at element $offset and replaces them with the elements of list. If list is omitted then the removed elements are simply deleted. If $length is omitted then everything from $offset to the end of @array is removed.

Two other very useful list processing functions are map and grep. map
is passed a block of code and a list and returns the list created by
running the given code on each element of the list in turn. Within the
code block, the element being processed is stored in $_. For example,
to create a list of squares, you could write code like this:

	@squares = map { $_ * $_ } @numbers;

If @numbers contains the integers from 1 to 10, then @square will end
up containing the squares of those integers from 1 to 100. It doesn’t
have to be true that each iteration only generates one element in the
new list; for example, the code

	@squares = map { $_, $_ * $_ } @numbers;

generates a list wherein each integer is followed by its square. grep
is also passed a block of code and a list. It executes the block of
code for each element on the list in turn, and if the code returns a
true value, then grep adds the original element to its return list.
The list returned, therefore, contains all the elements wherein the
code evaluated to true. For example, given a list containing random
integers,

	@odds = grep { $_ % 2 } @ints;

will put all of the odd values into the array @odds.

### Hashes

Hashes (or, as they were previously known, associative arrays)
provide a simple way to implement lookup tables in Perl. They
associate a value with a text key. You assign values to a hash in
much the same way as you do to an array. Here are some examples:

	%rings = (); # Creates an empty hash
	%rings = ('elves', 3, 'dwarves', 7);
	%rings = (elves => 3, dwarves => 7); # Another way to do the same
	thing
	$rings{men} = 9;
	$rings{great} = 1;

Notice that using the arrow operator (=>) has two advantages over the
comma. It makes the assignment easier to understand and it
automatically quotes the value to its left. Also notice that hashes
use different brackets to access individual elements and because,
like arrays, each element is a scalar, it is denoted with a $ rather
than a %. You can access the complete set of keys in a hash using the
function keys, which returns a list of the hash keys.

	@ring_types = keys %rings; # @ring_types is now ('men', 'great',
	'dwarves', 'elves')

There is a similar function for values.

	@ring_counts = values %rings; # @ring_counts is now (9, 1, 7, 3)

Notice that neither keys nor values is guaranteed to return the data
in the same order as it was added to the hash. They are, however,
guaranteed to return the data in the same order (assuming that you
haven’t changed the hash between the two calls).

There is a third function in this set called each which returns a
two-element list containing one key from the hash together with its
associated value. Subsequent calls to each will return another
key/value pair until all pairs have been returned, at which point an
empty array is returned. This allows you to write code like this:

	while ( ($type, $count) = each %rings) ) {
	print "$count $type ring(s)\n";
	}

You can also call each in a scalar context in which case it iterates
over the keys in the hash. The most efficient way to get the number of
key/value pairs in a hash is to assign the return value from either
keys or values to a scalar variable. !!! FOOTNOTE  3 Note that this
example also demonstrates that you can have variables of different
types with the same name. The scalar $ring_types in this example has
no connection at all with the array @ring_types in the earlier
example.!!!

	$ring_types = keys %rings; # $ring_types is now 4

You can access parts of a hash using a *hash slice* which is very
similar to the array slice discussed earlier.

	@minor_rings_types = ('elves', 'dwarves', 'men');
	@minor_rings{@minor_rings_types} = @rings{@minor_rings_types};
	# creates a new hash called %minor rings containing
	#
	elves => 3
	#
	dwarves => 7
	#
	men => 9

Note, once again, that a hash slice returns a list and therefore is
prefixed with @. The key list, however, is still delimited with { and
}. As a hash can be given values using a list, it is possible to use
the map function to turn a list into a hash. For example, the
following code creates a hash where the keys are numbers and the
values are their squares.

	%squares = map { $_, $_ * $_ } @numbers;

### More Information

For more information about Perl data types, see the perldata manual
page.

Operators
---------

Perl has all of the operators that you will be familiar with from
other languages— and a few more besides. You can get a complete list
of all of Perl’s operators in the perlop manual page. Let’s look at
some of the operators in more detail.

### Mathematical operators

The operators +, -, *, and / will add, subtract, multiply, and divide
their two operands respectively. % will find the modulus of the two
operands (that is the remainder when integer division is carried out).

Unary minus (-) reverses the sign of its single operand.

Unary increment (++) and decrement (--) operators will add or subtract
one from their operands. These operators are available both in prefix
and postfix versions. Both versions increment or decrement the
operand, but the prefix versions return the result after the operation
and the postfix versions return the results before the operation.

The exponentiation operator (**) raises its left-hand operand to the
power given by its right operand.

All of the binary mathematical operators are available in an
assignment version. For example,

	$x += 5;

is exactly equivalent to writing

	$x = $x + 5;

Similar to the mathematical operators, but working instead on strings,
the concatenation operator (.) joins two strings and the string
multiplication operator (x) returns a string made of its left operand
repeated the number of times given by its right operand. For example,

 $y = 'hello' x 3;

results in $y having the value “hellohellohello”.

In an array context, if the left operand is a list, then this
operator acts as a list repetition operator. For example,

 @a = (0) x 100;

makes a list with 100 elements, each of which contains the number 0,
and then assigns it to @a.

### Logical operators

Perl distinguishes between logical operators for use on numbers and
logical operators for use on strings. The former set uses the
mathematical symbols <, <=, ==, !=,
\>=, and > for less than, less than or equal to, equal to, not equal
to, greater than or equal to, and greater than, respectively, whereas
the string logical operators use lt, le, eq, ne, ge, and gt for the
same operations. All of these operators return 1 if their operands
satisfy the relationship and 0 if they don’t. In addition, there are
two comparison operators <=> (for numbers) and cmp (for strings) which
return –1, 0, or 1 depending on whether their first operand is less
than, equal to, or greater than their second operand.

For joining logical comparisons, Perl has the usual set of operators,
but once again it has two sets. The first set uses && for conjunction
and || for disjunction. These operators have very high precedence. The
second set uses the words and and or. This set has very low
precedence. The difference is best explained with an example. When
opening a file, it is very common in Perl to write something like
this:

	open DATA, 'file.dat' or die "Can't open file\n";

Notice that we have omitted the parentheses around the arguments to
open. Because of the low precedence of or, this code is interpreted
as if we had written

	open (DATA, 'file.dat') or die "Can't open file\n";

which is what we wanted. If we had used the high precedence version
of the operator instead, like this

	open DATA, 'file.dat' || die "Can't open file\n";

it would have bound more tightly than the comma that builds up the
list of arguments to open. Our code would, therefore, have been
interpreted as though we had written

	open DATA, ('file.dat' || die "Can't open file\n");

which doesn’t achieve the correct result.

The previous example also demonstrates another feature of Perl’s
logical operators—they are *short-circuiting*. That is to say they
only execute enough of the terms to know what the overall result will
be. In the case of the open example, if the call to open is
successful, then the left-hand side of the operator is true, which
means that the whole expression is true (as an or operation is true if
either of its operands is true). The right-hand side (the call to die)
is therefore not called. If the call to open fails, then the left-hand
side of the operator is false. The right-hand side must therefore be
executed in order to ascertain what the result is. This leads to a
very common idiom in Perl in which you will often see code like

	execute_code() or handle_error();

Unusually, the logical operators are also available in assignment
versions. The “or-equals” operator is the most commonly used of these.
It is used in code like

	$value ||= 'default';

This can be expanded into

	$value = $value || 'default';

from which it is obvious that the code sets $value to a default value
if it doesn’t already have a value.

Perl also has *bitwise* logical operators for and (&) or (|),
exclusive or (^), and negation (~). These work on the binary
representation of their two operands and, therefore, don’t always give
intuitively correct answers (for example ~1 isn’t equal to 0). There
are also left (<<) and right (>>) shift operators for manipulating
binary numbers. One use for these is to quickly multiply or divide
numbers by a power of two.

Flow of control
---------------

Perl has all of the standard flow of control constructs that are
familiar from other languages, but many of them have interesting
variations.

### Conditional execution

The if statement executes a piece of code only if an expression is
true.

	if ($location eq 'The Shire') {
	$safety = 1;
	}

The statement can be extended with an else clause.

	if ($location eq 'The Shire') {
	$safety++;
	} else {
	$safety--;
	}

 And further extended with elsif clauses.

	if ($location eq 'The Shire') {
	$safety++;
	} elsif ($location eq 'Mordor') {
	$safety = 0;
	} else {
	$safety--;
	}

Perl also has an unless statement which is logically opposite the if
statement—it executes unless the condition is true.

	unless ($location eq 'The Shire') {
	$panic = 1;
	}

Both the if and unless keywords can be used as *statement modifiers*.
This can often make for more readable code.

	$damage *= 2 if $name eq 'Aragorn';
	$dexterity++ unless $name eq 'Sam';

### Loops

 Perl has a number of looping constructs to execute a piece of code a
number of times.

#### for loop

The for loop has the syntax:

	for (initialisation; test; increment) {
	statements;
	}

For example,

	for ($x = 1; $x <= 10; ++$x) {
	print "$x squared is ", $x * $x, "\n";
	}

The loop will execute until the test returns a false value. It is
probably true to say that this loop is very rarely used in Perl, as
the foreach loop discussed in the next section is far more flexible.

#### foreach loop

The foreach loop has the syntax:

	foreach var (list) {
	statements;
	}

For example, the previous example can be rewritten as:

	foreach my $x (1 .. 10) {
	print "$x squared is ", $x * $x, "\n";
	}

which, to many people, is easier to understand as it is less complex.
You can even omit the loop variable, in which case each element in
the list in turn is accessible as $_.

	foreach (1 .. 10) {
	print "$_ squared is ", $_ * $_, "\n";
	}

This loop will execute until each element of the list has been
processed. It is often used for iterating across the contents of an
array like this:

	foreach (@data) {
	process($_);
	}

### while loop

The while loop has the syntax:

	while (condition) {
	statements
	}

For example,

	while ($data = get_data()) {
	process($data);
	}

This loop will execute until the condition evaluates to a false value.

### Loop control

There are three keywords which can be used to alter the normal
execution of a loop: next, last, and redo. next immediately starts the
next iteration of the loop, starting with the evaluation of any test
which controls whether the loop should continue to be executed. For
example, to ignore empty elements of an array you can write code like
this:

	foreach my $datum (@data) {
	next unless $datum;
	process($datum);
	}

redo also returns to the start of the loop block, but does not
execute any test or iteration code. Suppose you were prompting the
user for ten pieces of data, none of which could be blank. You could
write code like this:

	foreach my $input (1 .. 10) {
	print "\n$input> ";
	$_; = <STDIN>;
	redo unless $_'
	}

last immediately exits the loop and continues execution on the
statement following the end of the loop. If you were processing data,
but wanted to stop when you reached a number that was negative, you
could write code like this:

	foreach my $datum (@data) {
	last if $datum < 0;
	process($datum);
	}

All of these keywords act on the innermost enclosing loop by default.
If this isn’t what you want then you can put a label in front of the
loop keyword (for, foreach, or while) and refer to it in the next,
redo, or last command. For example, if you were processing lines and
words from a document, you could write something like this:

	LINE:
	foreach my $line (getlines()) {
	WORD:
	foreach $word (getwords($line)) {
	last WORD if $word eq 'next';
	last LINE if $word eq 'end';
	process($word);
	}
	}

Subroutines
-----------

Subroutines are defined using the keyword sub like this:

	sub gollum {
	print "We hatesss it forever!\n";
	}

and are called like this:

	&gollum;

or like this

	gollum();

or (if the definition of the subroutine has already been seen by the
compiler) like this:

	gollum;

Within a subroutine, the parameters are available in the special array
@_. These parameters are passed by reference, so changing this array
will alter the values of the variables in the calling code. !!!
FOOTNOTE  4 This isn’t strictly true, but it’s true enough to be a
reasonable working hypothesis. For the full gory details see perldoc
perlsub. !!! To simulate parameter passing by value, it is usual to
assign the parameters to local variables within the subroutine like
this:

	sub example {
	my ($arg1, $arg2, $arg4) = @_;
	# Do stuff with $arg1, $arg2 and $arg3
	}

Any arrays or hashes that are passed into subroutines this way are
flattened into one array. Therefore if you try to write code like
this:

	# Subroutine to print one element of an array
	# N.B. This code doesn't work.
	sub element {
	my (@arr, $x) = @_;
	print $arr[$x];
	}
	my @array = (1 .. 10);
	element(@array, 4);

it won’t work because, within the subroutine, the assignment to @arr
doesn’t know when to stop pulling elements from @_ and will,
therefore, take all of @_, leaving nothing to go into $x which
therefore ends up containing the undef value.

If you were to pass the parameters the other way round like this:

	# Subroutine to print one element of an array
	# N.B. Better than the previous version.
	sub element {
	my ($x, @arr) = @_;
	print $arr[$x];
	}
	my @array = (1 .. 10);
	element(4, @array);

it would work, as the assignment to $x would pull one element off of
@_ leaving the rest to go into @arr. An even better way, however, is
to use references, as we’ll see later.

A subroutine returns the value of the last statement that it executes,
although you can also use the return function to explicitly return a
value from any point in the subroutine. The return value can be a
scalar or a list. Perl even supplies a function called wantarray which
tells you whether your subroutine was called in scalar or array
context so that you can adjust your return value accordingly.

More information about creating and calling subroutines can be found
in the perlsub manual page.

References
----------

References are the key to building complex data structures in Perl
and, as such, are very important for data munging. They work somewhat
like pointers in languages like C, but are more useful. They know, for
example, the type of the object that they are pointing at. A reference
is a scalar value and can, therefore, be stored in a standard scalar
variable.

### Creating references

You can create a reference to a variable in Perl by putting a
backslash character (\) in front of the variable name. For example:

	$scalar = 'A scalar';
	@array = ('An', 'Array');
	%hash = (type => 'Hash);
	$scalar_ref = \$scalar;
	$array_ref = \@array;
	$hash_ref = \%hash;

Sometimes you’d like a reference to an array or a hash, but you don’t
wish to go to the bother of creating a variable. In these cases, you
can create an *anonymous* array or hash like this:

	$array_ref = ['An', 'Array'];
	$hash_ref = {type => 'Hash'};

The references created in this manner are no different than the ones
created from variables, and can be dereferenced in exactly the same
ways.

### Using references

To get back to the original object that the scalar points at, you
simply put the object’s type specifier character (i.e., $, @, or %) in
front of the variable holding the reference. For example:

	$orig_scalar = $$scalar_ref;
	@orig_array = @$array_ref;
	%orig_hash = %$hash_ref;

If you have a reference to an array or a hash, you can access the
contained elements using the dereferencing operator (->). For
example:

	$array_element = $array_ref->[1];
	$hash_element = $hash_ref->{type};

To find out what type of object a reference refers to, you can use
the ref function. This function returns a string containing the name
of the object type. For example:

	print ref $scalar_ref; # prints 'SCALAR'
	print ref $array_ref;
	# prints 'ARRAY'
	print ref $hash_ref;
	# prints 'HASH'

### References to subroutines

You can also take references to subroutines. The syntax is exactly
equivalent for other object types. Remember that the type specifier
character for a subroutine is &. You can therefore do things like
this:

	sub my_sub {
	print "I am a subroutine";
	}
	$sub_ref = \&my_sub;
	&$sub_ref;
	# executes &my_sub
	$sub_ref->(); # another way to execute my_sub (allowing parameter
	passing)

 You can use this to create references to anonymous subroutines (i.e.,
 subroutines without names) like this:

	$sub_ref = sub { print "I'm an anonymous subroutine" };

Now the only way to execute this subroutine is via the reference.

### Complex data structures using references

I said at the start of this section that references were the key to
creating complex data structures in Perl. Let’s take a look at why
this is. Recall that each element of an array or a hash can only
contain scalar values. If you tried to create a two-dimensional array
with code like this:

	# NOTE: This code doesn't work
	@array_2d = ((1, 2, 3), (4, 5, 6), (7, ,8, 9));

the arrays would all be flattened and you would end up with a
one-dimensional array containing the numbers from one to nine.
However, with references we now have a way to refer to an array using
a value which will fit into a scalar variable. We can, therefore, do
something like this:

	@arr1 = (1, 2, 3);
	@arr2 = (4, 5, 6);
	@arr3 = (7, 8, 9);
	@array_2d = (\@arr1, \@arr2, \@arr3);

or (without the need for intermediate array variables):

	@array_2d = ([1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]);

Of course, having put our data into a two-dimensional array, !!!
FOOTNOTE  5 Or, at least, something that simulates one rather well.
!!! we need to know how we get the data back out again. It should be
possible to work this out, given what we already know about arrays and
references.

Suppose we want to access the central element of our 2-D array (the
number 5). Actually, our array isn’t a 2-D array at all, it is really
an array which contains references to arrays in its elements. The
element $array_2d[1] contains a reference to an anonymous array which
contains the numbers 4, 5, and 6. One way to do it would, therefore,
be to use an intermediate variable like this:

	$row = $array_2d[1];
	@row_arr = @$row;
	$element = $row_arr[1];

While this will work, Perl gives us ways to write the same thing more
efficiently. In particular, the notation for accessing an object given
a reference to it has some extensions to it. Where previously we have
seen syntax like @$arr\_ref give us the array referred to by $arr\_ref,
there is a more general syntax which looks like:

	@{block}

in which *block* is any piece of Perl code that returns a reference to
an array (the same is true, incidentally, of hashes). In our case, we
can, therefore, use this to our advantage and use

	@{$array_2d[1]}

to get back the required array. As this is now the array in which we
are interested, we can use standard array syntax to get back our
required element, that is we replace the @ with a $ and put the
required index in [ .. ] on the end. Our required element is therefore
given by the expression:

	${$array_2d[1]}[1]

That does the job, but it looks a bit ugly and, if there were more
than one level of indirection, it would just get worse. Surely there’s
another way? Remember when we were accessing elements of an array
using the $arr\_ref->[0] syntax? We can make use of that. We said that
$array\_2d[1] gives us a reference to the array that we need. We can,
therefore, use the -> syntax to access the individual elements of that
array. The element that we want is given by:

	$array_2d[1]->[1];

which is much simpler. There is one further simplification that we can
make. Because the only way to have multi-dimensional data structures
like these is to use references, Perl knows that any multilevel
accesses must involve references. Perl therefore assumes that there
must be a deferencing arrow (->) between any two successive sets of
array or hash brackets and, if there isn’t one there, it acts as
though it were there anyway. This means that we can further simplify
our expression to:

	$array_2d[1][1];

This makes our structure look a lot like a traditional two-dimensional
array in a language like C or BASIC.

In all of the examples of complex data structures we have used arrays
that contain references to arrays; but it’s just as simple to use
arrays that contain hash references, hashes that contain hash
references, or hashes that contain array references (or, indeed, any
even more complex structures). Here are a few examples:

	@hobbits = ({ fname => 'bilbo',
	lname => 'baggins' },
	{ fname => 'frodo',
	lname => 'baggins' },
	{ fname => 'Sam',
	lname => 'Gamgee' });
	foreach (@hobbits) {
	print $_->{fname}, "\n";
	}
	%races = ( hobbits => [ 'Bilbo', 'Frodo', 'Sam'],
	men => ['Aragorn', 'Boromir', 'Theoden'],
	elves => ['Elrond', 'Galadriel', 'Legolas'],
	wizards => ['Gandalf', 'Saruman', 'Radagast'] );
	foreach (keys %races) {
	print "Here are some $_\n";
	print "@{$races{$_}}\n\n";
	}

### More information on references and complex data structures

The manual page perlref contains a complete guide to references, but
it can sometimes be a little terse for a beginner. The perlreftut
manual page is a kinder, gentler introduction to references. The
perllol manual page contains an introduction to using Perl for the
purpose of creating multi-dimensional arrays (or lists of lists—hence
the name). The perldsc manual page is the data structures cookbook
and contains information about building other kinds of data
structures. It comes complete with a substantial number of detailed
examples of creating and using such structures.

More information on Perl
------------------------

[Chapter 12](/chapter12.html) contains details of other places to obtain useful
information about Perl. In general the best place to start is with
the manual pages which come with your distribution of Perl. Typing
perldoc perl on your command line will give you an overview of the
various manual pages supplied and should help you decide which one to
read for more detailed information.
