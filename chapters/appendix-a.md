Appendix A: Modules Reference
=============================

In this book, we have looked at a number of Perl modules. Some of
them are standard modules that come bundled with your Perl
distribution; others can be obtained from the CPAN.

In order to avoid interrupting the flow of the narrative chapters, I
have not given detailed descriptions of the modules earlier in the
book. Instead, I have gathered all of that information in this
appendix. In all cases, this is not a complete reference for the
module, but should be enough to take you beyond the examples in the
book. Full references will come with the module and can be accessed
by typing `perldoc <module_name>` at your command line. For example,
typing

	perldoc DBI

will give you a full description of DBI.pm.

DBI
---

The following is a brief list of the most useful DBI functions.

### Functions called on the DBI class


These functions are called via the DBI class itself.

* `DBI->available_drivers` Returns a list of the available DBD modules.

* `DBI->connect($data_source, $user, $password [, \%attributes])` Creates a connection to a database and returns a handle which you use to carry out further actions on this connection.

* `$data_source` will always start with “dbi:driver_name:”. The rest of the string is driver dependent.

* `$user` and `$password` are passed unchanged to the database driver. They will usually be a valid database user and associated password.

* `\%attributes` is a reference to an optional hash of attribute values. Currently supported attributes are `PrintError`, `RaiseError`, and `AutoCommit`. These attributes are the keys of the hash and the associated values should be Boolean expressions (e.g., 0 or 1). The default values are the equivalents of setting the parameter to `{PrintError => 1, RaiseError => 0, AutoCommit => 1}`.

* `DBI->data_sources($driver)` Returns a list of data sources available for the given driver.

* `DBI->trace($level [, $file])` Controls the amount of trace information to be displayed (or written to the optional file). Calling trace via the DBI class will enable tracing on all handles. It is also possible to control trace levels at the handle level. The trace levels are described in detail in the DBI documentation. Full instructions on how to install CPAN modules can be found in perldoc perlmodinstall.

### Attributes of the DBI class

The following attribute can be accessed through the DBI class.

* `$DBI::err`, `$DBI::errstr` Returns the most recent database driver error encountered. A numeric error code is returned by `$DBI::err` and a text string is returned by `$DBI::errstr`.

### Functions called on any DBI handle

The following functions are called via any valid DBI handle (usually
a database handle or a statement handle).

* `$h->err`, `$h->errstr` Returns the most recent database driver error encountered by this handle. A numeric error code is returned by $h->err and a text string is returned by `$h->errstr`.

* `$h->trace($level [, $file])` Similar to `DBI->trace`, but works at the handle level.

### Attributes of any DBI handle

The following attributes can be accessed via any DBI handle.

* `$h->{warn}` Set to a Boolean value which determines whether warnings are raised for certain bad practices.

* `$h->{Kids}` Returns the number of statement handles that have been created from it and not destroyed.

* `$h->{PrintError}` Set to a Boolean value which determines whether errors are printed to STDERR rather than just returning error codes. The default for this attribute is on.

* `$h->{RaiseError}` Set to a Boolean value which determines whether errors cause the program to die rather than just returning error codes. The default for this attribute is off.

* `$h->{Chopblanks}` Set to a Boolean value which determines whether trailing blanks are removed from fixed-width character fields. The default for this value is off.

* `$h->{LongReadLen}` Determines the amount of data that a driver will read when reading a large field from the database. These fields are often known by such names as text, binary, or blob. The default value is 0, which means that long data fields are not returned.

* `$h->{LongTruncOk}` Set to a Boolean value which determines whether a fetch should fail if it attempts to fetch a long column that is larger than the current value of LongReadLen. The default value is 0 which means that truncated fetches raise an error.

### Functions called on a database handle

The following functions are called on a valid database handle.

* `$dbh->selectrow_array($statement [, \%attr [, @bind_values]])` Combines the prepare, execute, and fetchrow_array functions into one function call. When it is called in a list context it returns the first row of data returned by the query. When it is called in a scalar context it returns the first field of the first row. See the separate functions for more details on the parameters.

* `$dbh->selectall_arrayref($statement [, \%attr [, @bind_values]])` Combines the prepare, execute, and fetchall_arrayref functions into a single function call. It returns a reference to an array. Each element of the array contains a reference to an array containing the data returned. See the separate functions for more details on the parameters.

* `$dbh->prepare($statement [, \%attr])` Prepares an SQL statement for later execution against the database and returns a statement handle. This handle can later be used to invoke the execute function. Most database drivers will, at this point, pass the statement to the database to ensure that it compiles correctly. If there is a problem, prepare will return `undef`.

* `$dbh->do($statement, \%attr, @bind_values)` Prepares and executes an SQL statement. It returns the number of rows affected (–1 if the database driver doesn’t support this) or `undef` if there is an error. This is useful for executing statements that have no return sets, such as updates or deletes.

* `$dbh->commit`, `$dbh->rollback` Will commit or rollback the current database transaction. They are only effective if the AutoCommit attribute is set to 0.

* `$dbh->disconnect` Disconnects the database handle from the database and frees any associated memory.

* `$dbh->quote` Applies whatever transformations are required to quote dangerous characters in a string, so that the string can be passed to the database safely. For example, many database systems use single quotes to delimit strings so that any apostrophes in a string can cause a syntax error. Passing the string through the quote function will escape the apostrophe in a database-specific manner.

### Database handle attributes

The following attribute can be accessed through a database handle.

* `$dbh->{AutoCommit}` Set to a Boolean value which determines whether or not each statement is committed as it is executed. The default value is 1, which means that it is impossible to roll back transactions. If you want to be able to roll back database changes then you must change this attribute to 0.

### Functions called on a statement handle

The following functions are all called via a valid statement handle.

* `$sth->bind_param($p_num, $bind_value[, $bind_type])` Used to bind a value to a placeholder in a prepared SQL statement. Placeholders are marked with the question mark character (?). The `$p_num` parameter indicates which placeholder to use (placeholders are numbered from 1) and the $bind_values is the actual data to use. For example:

	my %data = (LON => 'London', MAN => 'Manchester', BIR => 'Birmingham');
	my $sth = $dbh->prepare('insert into city (code, name) values (?,?)');

	foreach (keys %data) {
	  $sth->bind_param(1, $_);
	  $sth->bind_param(2, $data{$_});
	  $sth->execute;
	}

* `$sth->bind_param_inout($p_num, \\$bind_value, $max_len [, $bindtype])` Like `bind_param` but it also enables variables to be updated by the results of the statement. This function is often used when the SQL statement is a call to a stored procedure. Note that the `$bind_value` must be passed as a reference to the variable to be used. The `$max_len` parameter is used to allocate the correct amount of memory to store the returned value.

* `$sth->execute([@bind_values])` Executes the prepared statement on the database. If the statement is an insert, delete, or update then when this function returns, the insert, delete, or update will be complete. If the statement was a select statement, then you will need to call one of the fetch functions to get access to the result set. If any parameters are passed to this function, then bind_param will be run for each value before the statement is executed.

* `$sth->fetchrow_arrayref`, `$sth->fetch` (`fetch` is an alias for `fetchrow_arrayref`) Fetches the next row of data from the result set and returns a reference to an array that holds the data values. Any NULL data items are returned as `undef`. When there are no more rows to be returned, the function returns `undef`.

* `$sth->fetchrow_array` Similar to `fetchrow_arrayref`, except that it returns an array containing the row data. When there are no more rows to return, `fetchrow_array` returns an empty array.

* `$sth->fetchrow_hashref` Similar to `fetchrow_arrayref`, except that it returns a hash containing the row data. The keys of the hash are the column names and the values are the data items. When there are no more rows to return, this function returns `undef`.

* `$sth->fetchall_arrayref` Returns all of the data from a result set at one time. The function returns a reference to an array. Each element of the array is a reference to another. Each of these second-level arrays represents one row in the result set and each element contains a data item. This function returns an empty array if there is no data returned by the statement.

* `$sth->finish` Disposes of the statement handle and frees up any memory associated with it.

* `$sth->bind_col($column_number, \$var_to_bind)` Binds a column in a return set to a Perl variable. Note that you must pass a reference to the variable. This means that each time a row is fetched, the variable is automatically updated to contain the value of the bound column in the newly fetched row. See the code example under `bind_columns` for more details.

* `$sth->bind_columns(@list_of_refs_to_vars)` Binds each variable in the list to a column in the result set (the first variable in the list is bound to the first column in the result set, and so on). Note that the list must contain references to the variables. For example:

	my ($code, $name);
	my $sth = $dbh->prepare(‘select code, name from city’);
	$sth->execute;
	$sth->bind_columns(\$code, \$name);

	while ($sth->fetch) {
	  print “$code: $name\n";
	}

### Statement handle attributes

The following attributes can be accessed through a statement handle.

* `$sth->{NUM_OF_FIELDS}` Contains the number of fields (columns) that the statement will return.

* `$sth->{NAME}` Contains a reference to an array which contains the names of the fields that will be returned by the statement.

* `$sth->{TYPE}` Contains a reference to an array which contains an integer for each field in the result set. This integer indicates the data type of the field using an international standard.

* `$sth->{NULLABLE}` Contains a reference to an array which contains a value for each field that indicates whether the field can contain NULL values. The valid values are 0 = no, 1 = yes, and 2 = don’t know.

Number::Format
--------------

The following is a brief reference to Number::Format.

### Attributes

These are the attributes that can be passed to the new method.

* `THOUSANDS_SEP` The character which is inserted between groups of three digits. The default is a comma.

* `DECIMAL_POINT` The character which separates the integer and fractional parts of a number. The default is a decimal point.

* `MON_THOUSANDS_SEP` The same as `THOUSANDS_SEP`, but used for monetary values (formatted using format_price). The default is a comma.

* `MON_DECIMAL_POINT` The same as `DECIMAL_POINT`, but used for monetary values (formatted using format_price). The default is a decimal point.

* `INT_CURR_SYMBOL` The character(s) used to denote the currency. The default is USD .

* `DECIMAL_DIGITS` The number of decimal digits to display. The default is two.

* `DECIMAL_FILL` A Boolean flag indicating whether or not the formatter should add zeroes to pad out decimal numbers to DECIMAL_DIGITS places. The default is off.

* `NEG_FORMAT` The format to use when displaying negative numbers. An 'x' marks where the number should be inserted. The default is -x.

* `KILO_SUFFIX` The letter to append when format_bytes is formatting a value in kilobytes. The default is K.

* `MEGA_SUFFIX` The letter to append when format_bytes is formatting a value in megabytes. The default is M.

### Methods

These are the methods that you can call to format your data.

* `round($number, $precision)` Rounds the given number to the given precision. If no precision is given, then `DECIMAL_DIGITS` is used. A negative precision will decrease the precision before the decimal point. This method doesn’t make use of the `DECIMAL_POINT` or `THOUSANDS_SEP` values.

* `format_number($number, $precision, $trailing_zeroes)` Formats the given number to the given precision and pads with trailing zeroes if `$trailing_zeroes` is true. If neither `$precision` nor `$trailing_zeroes` are given then the values in `DECIMAL_DIGITS` and `DECIMAL_FILL` are used instead. This method inserts the value of `THOUSANDS_SEP` every three digits and replaces the decimal point with the value of `DECIMAL_POINT`.

* `format_negative($number, $picture)` Formats the given number using the given picture. If a picture is not given then the value of `NEG_FORMAT` is used instead. In the picture, the character “x” should be used to mark the place where the number should go.

* `format_picture($number, $picture)` Formats the given number using the given picture. The picture should contain the character `#` wherever you want a digit from `$number` to appear. If there are fewer digits in `$number` than there are `#` characters, then the output is left-padded with spaces and any occurrences of `THOUSANDS_SEP` to the left of the number are removed. If there are more digits in `$number` than there are `#` characters in `$picture` then all of the `#` characters are replaced with `*` characters.

* `format_price($number, $precision)` Works like `format_number`, except that the values of `MON_THOUSANDS_SEP` and `MON_DECIMAL_POINT` are used, and the value of `INT_CURR_SYMBOL` is prepended to the result.

* `format_bytes($number, $precision)` Works like `format_number` except that numbers larger than 1024 will be divided by 1024 and he value of `KILO_SUFFIX` will be appended and numbers larger than 10242 will be divided by 10242 and the value of `MEGA_SUFFIX` will be appended.

* `unformat_number($formatted_number)` The parameter `$formatted_number` must be a number that has been formatted by `format_number`, `format_price` or `format_picture`. The formatting is removed and an unformatted number is returned.

Time::Piece
-----------

[Time::Piece](https://metacpan.org/pod/Time::Piece) replaces Perl's
built-in `localtime`/`gmtime` functions with versions that return an
object instead of a plain list of values.

### Functions

* `localtime($epoch_seconds)`, `gmtime($epoch_seconds)` Both overridden by Time::Piece to return a Time::Piece object (in local time and UTC respectively) instead of the usual nine-element list. Called with no argument, they use the current time.

### Constructors

* `Time::Piece->strptime($string, $format)` Parses `$string` according to `$format` (using the same format specifiers as `strftime`, below) and returns a Time::Piece object. This is the usual way to build an object for an arbitrary date, since there's no plain `new` constructor that takes year/month/day directly.

### Methods

* `$t->strftime($format)` Formats the date/time using the same format specifiers as `POSIX::strftime`.

* `$t->ymd`, `$t->mdy`, `$t->dmy` Return the date as a string, in ISO (`2026-09-21`), US (`09/21/2026`), or UK (`21/09/2026`) order respectively. All three take an optional separator argument, e.g. `$t->ymd('/')`.

* `$t->year`, `$t->mon`, `$t->mday`, `$t->hour`, `$t->min`, `$t->sec` Return the individual components of the date/time. Unlike the built-in `localtime`, `mon` returns 1–12 and `year` returns the full four-digit year—no `+1` or `+1900` needed.

* `$t->day_of_week` Returns 0–6, with Sunday as 0—the same convention as the seventh element of the list returned by the built-in `localtime`.

* `$t->day_of_year` Returns 1–366.

* `$t->epoch` Returns the number of seconds since the epoch, the same value you'd pass to `localtime`/`gmtime`.

* `$t + $seconds`, `$t - $seconds` Add or subtract a number of seconds. Time::Piece overloads the usual arithmetic operators, and Time::Seconds (bundled with Time::Piece) exports constants like `ONE_DAY`, `ONE_HOUR`, and `ONE_WEEK` to make this readable, as in `$t + ONE_DAY`.

* `$t1 - $t2` Subtracting one Time::Piece object from another returns a Time::Seconds object, which stringifies to a number of seconds but also has methods like `days`, `hours`, and `minutes` for reading the difference in other units.

DateTime
--------

[DateTime](https://metacpan.org/pod/DateTime) is a heavier, CPAN-only
alternative to Time::Piece, built around a large family of
`DateTime::*` modules that all share the same object representation.

### Constructors

* `DateTime->new(%args)` Builds an object for an arbitrary date/time directly. Recognized keys are `year`, `month`, `day`, `hour`, `minute`, `second`, and `time_zone`; all except `year` are optional, and `time_zone` defaults to UTC.

* `DateTime->now(%args)`, `DateTime->today(%args)` Return an object for the current date and time, or just the current date (time set to midnight). Both default to the UTC time zone—pass `time_zone => 'local'` (or a named zone like `'Europe/London'`) for anything else.

### Methods

* `$dt->add(%args)`, `$dt->subtract(%args)` Move the date/time forward or backward. Recognized keys are `years`, `months`, `weeks`, `days`, `hours`, `minutes`, and `seconds`, and any combination can be passed in one call.

* `$dt1->subtract_datetime($dt2)` (or the overloaded `$dt1 - $dt2`) Returns a [DateTime::Duration](https://metacpan.org/pod/DateTime::Duration) object representing the difference between two dates, with its own `years`, `months`, `weeks`, and `days` methods—these account properly for varying month lengths and leap years, which a simple day count can't.

* `$dt->year`, `$dt->month`, `$dt->day`, `$dt->hour`, `$dt->minute`, `$dt->second`, `$dt->day_of_week` Return the individual components; `day_of_week` returns 1–7 with Monday as 1 (note this is a different convention to Time::Piece's `day_of_week`).

* `$dt->strftime($format)` Formats the date/time using the same format specifiers as `POSIX::strftime`.

* `$dt->ymd`, `$dt->mdy`, `$dt->dmy` Return the date as a string, using the same conventions as the equivalent Time::Piece methods.

* Printing a DateTime object directly (or calling `$dt->iso8601` / `$dt->datetime`) gives an ISO 8601 formatted string.

There's also a large family of `DateTime::Format::*` modules for
parsing and formatting particular standards (`DateTime::Format::HTTP`
for the date format used in HTTP headers, for example), and
`DateTime::Calendar::*` modules for viewing a DateTime object through
a non-Gregorian calendar. See [Chapter 6](ch010.xhtml) for examples of
both.

LWP::Simple
-----------

In [Chapter 9](ch014.xhtml) we took a brief look at the LWP::Simple module. Here is
a slightly less brief look at the functions that this module
provides. For more information on using this module see the lwpcook
manual page which comes with the LWP bundle of modules.

* `$page = get($url)` Returns the document which is found at the given URL. It returns only the document without any of the HTTP headers. Returns `undef` if the request fails.

* `($content_type, $document_len, $mod_time, $expiry_time, $server) = head($url)` Returns various information from the HTTP header that is returned when the given URL is requested. Returns an empty list if the request fails.

* `$http_code = getprint($url)` Gets the document from the given URL and prints it to STDOUT. If the request fails, it prints the status code and error message. The return value is the HTTP response code.

* `$http_code = getstore($url, $file)` Gets the document from the given URL and stores it in the given file. The return value is the HTTP response code.

* `$http_response = mirror($url, $file)` Mirrors the document at the given URL into the given file. If the document hasn’t changed since the file was created then no action is taken. Returns the HTTP response code.

HTML::Parser
------------

Here is a brief guide to the methods of the HTML::Parser object.

* `$parser = HTML::Parser->new(%options_and_handlers)` Creates an instance of the HTML parser object. For details of the various options and handlers that can be passed to this method, see the description later in this section. Returns the new parser object or `undef` on failure.

* `$parser->parse($html)` Parses a piece of HTML text. Can be called multiple times.

* `$parser->eof` Tells the parser the you have finished calling parse.

* `$parser->parse_file($file_name)` Parses a file containing HTML.

* `$parser->strict_comment($boolean)` Many popular browsers (including Netscape Navigator and Microsoft Internet Explorer) parse HTML comments in a way which is subtly different than the HTML standard. Calling this function and passing it a true value will switch on strict (*i.e.*, in line with the HTML specification) comment handling. As I was completing the final edits of this book, there were some moves towards correcting this discrepancy.

* `$parser->strict_names($boolean)` This method has similar functionality to `strict_comment`, but deals with certain browsers’ ability to understand broken tag and attribute names.

* `$parser->xml_mode($boolean)` When `xml_mode` is switched on, the parser handles certain XML constructs which aren’t allowed in HTML. These include combined start and end tags (*e.g.*, `<br/>`) and XML processing instructions.

* `$parser->handler(%hash)` Allows you to change handler functions. The arguments are similar to those in the handler arguments optionally passed to the new method. These are discussed in the next section.

### Handlers

To do anything useful with HTML::Parser, you need to define handlers
which are called when the parser encounters certain constructs in the
HTML document. You can define handlers for the events shown in table
A.1.

| Handler    | Called when …                        |
|------------|--------------------------------------|
|declaration | an HTML DOCTYPE declaration is found |
|start       | the start of an HTML tag is found    |
|end         | the end of an HTML tag is found      |
|text        | plain text is found                  |
|comment     | an HTML comment is found             |
|process     | a processing instruction is found    |

Table: **HTML::Parser** handlers

Each of these handlers can be defined in two ways. Either you can pass
details of the handler to the new method or you can use the handler
method after creating the parser object, but before parsing the
document. Here are examples of both uses.

    my $parser = HTML::Parser->new(start_h => [\&start,	'tagname,attr']);
    $parser->handler(start => [\&start, 'tagname,attr']);

In both examples we have set the start handler to be a function
called start which must be defined somewhere within our program. The
only difference between the two versions is that when using new, the
event name (*i.e.*, `start`) must have the string `_h` appended to it. In
both examples the actual subroutine to be called is defined in a
two-element array. The first element of the array is a reference to
the subroutine to be called and the second element is a string
defining the arguments which the subroutine expects. The various
values that this string can contain are listed in table A.2.

| Name | Description | Data type |
|------|-------------|-----------|
| self | The current parser object | Reference to the object |
| tokens | The list of tokens which makes up the current event | Reference to an array |
| tokenpos | A list of the positions of the tokens in the original text. Each token has two numbers; the first is the offset of the start of the token, and the second is the length of the token. | Reference to an array |
| token0 | The text of the first token (this is the same as `$tokens->[0]`) | Scalar value |
| tagname | The name of the current tag | Scalar value |
| attr | The name and values of the attributes of the current tag | Reference to a hash |
| attrseq | A list of the names of the attributes of the current tag in the order that they appear in the original document | Reference to an array |
| text | The source text for this event | Scalar value |
| dtest | The same as “text” but with any HTML entities (*e.g.*, `&amp;`) decoded | Scalar value |
| is_cdata | True if event is in a CDATA section | Scalar value |
| offset | The offset (in bytes) of the start of the current event from the start of the HTML document | Scalar value |
| length | Length (in bytes) of the original text which constitutes the event | Scalar value |
| event | The name of the current event | Scalar value |
| line | The number of the line in the document where this event started | Scalar value |
| ' ' | Any literal string is passed to the handler unchanged | Scalar value |
| undef | An undef value | Scalar value |

Table: Argument specification strings

HTML::LinkExtor
---------------

HTML::LinkExtor is a subclass of HTML::Parser and, therefore, all of
that class’s methods are available. Here is a list of extra methods
together with methods that have a different interface.

* `$parser = $HTML::LinkExtor->new($callback, $base)` Creates an HTML::LinkExtor object. Both of its parameters are optional. The first parameter is a reference to a function which will be called each time a link is found in the document being parsed. This function will be called with the tag name in lower case as the first argument followed by a list of attributes and values. Only link attributes will be included. The second parameter is a base URL used to convert relative URLs to absolute ones (you will need the URI::URL module installed in order to use this functionality).

* `@links = $parser->links` Having parsed a document, this method returns a list of all of the links found. Each element of the array returned is a reference to another array. This second level array contains the same values as would have been passed to the links callback if you had defined one in the call to new. If you do provide a link callback function, then links will return an empty array.

HTML::TokeParser
----------------

HTML::TokeParser is another subclass of HTML::Parser; however, it is
not recommended that you call any of the methods from the superclass.
You should only use the methods defined by HTML::TokeParser.

* `$parser = HTML::TokeParser->new($document)` Creates an HTML::TokeParser object. The single parameter defines the document to be parsed in one of a number of possible ways. If the method is passed a plain scalar then it is taken as the name of a file to open and read. If the method is passed a reference to a scalar then it assumes that the scalar contains the entire text of the document. If it is passed any other type of object (for example, a filehandle) then it assumes that it can read data from the object as it is required.

* `$token = $parser->get_token` Returns the next token from the document (or `undef` when there are no more tokens). A token consists of a reference to an array. The first element in the array is a character indicating the type of the token (`S` for start tag, `E` for end tag, `T` for text, `C` for comment, and `D` for a declaration). The remaining elements are the same as the parameters to the appropriate method of the HTML::Parser object.

* `$parser->unget_token` You can’t know what kind of token you will get next until you have received it. If you find that you don’t need it yet, you can call this method to return it to the token stack to be given to you again the next time you call `get_token`.

* `$tag = $parser->get_tag($tag)` Returns the next start or end tag in the document. The parameter is optional and, if it is used, the method will return the next tag of the given type. The method returns `undef` if no more tokens (or no more tokens of the given type) are found. The tag is returned as a reference to an array. The elements of the array are similar to the elements in the array returned from the `get_token` method, but the character indicating the token type is missing and the name of an end tag will have a `/` character prepended.

* `$text = $parser->get_text($endtag)` Returns all text at the current position of the document. If the optional parameter is omitted it returns the text up to the next tag. If an end tag is given then it returns all text up to the next end tag of the given type.

* `$text = $parser->get_trimmed_text($endtag)` Works in the same way as the `get_text` method, except that any sequences of white space characters are collapsed to a single space, and any leading or trailing white space is removed.

HTML::TreeBuilder
-----------------

HTML::TreeBuilder inherits all of the methods from HTML::Parser and
HTML:: Element. It builds an HTML parse tree when each node is an
HTML::Element object. It only has a few methods of its own, and here
is a list of them.

* `$parser->implicit_tags($boolean)` If the boolean value is true then the parser will try to deduce where missing elements and tags should be.

* `$parser->implicit_body_p_tag($boolean)` If the boolean value is true, the parser will force there to be a `<p>` element surrounding any elements which should not be immediately contained within a `<body>` tag.

* `$parser->ignore_unknown($boolean)` Controls what the parser does with unknown HTML tags. If the boolean value is true then they are simply ignored.

* `$parser->ignore_text($boolean)` If the boolean value is true then the parser will not represent any of the text of the document within the parser tree. This can be used (and save a lot of storage space) if you are only interested in the structure of the document.

* `$parser->ignore_ignorable_whitespace($boolean)` If the boolean value is true then the parser will not build nodes for white space which can be ignored without affecting the structure of the document.

* `$parser->p_strict($boolean)` If the boolean value is true then the parser will be very strict about the type of elements that can be contained within a `<p>` element and will insert a closing `</p>` tag if it is necessary.

* `$parser->store_comments($boolean)`, `$parser->store_declarations($boolean)`, `$parser->store_pis($boolean)` These control whether or not comments, declarations, and processing instructions are stored in the parser tree.

* `$parser->warn($boolean)` Controls whether or not warnings are displayed when syntax errors are found in the HTML document.

Web::Query
----------

[Web::Query](https://metacpan.org/pod/Web::Query) gives you a
jQuery-style, CSS-selector interface for scraping HTML, built on top
of HTML::TreeBuilder.

### Functions

* `wq($thing)` Shortcut for `Web::Query->new($thing)`, exported by default.

### Constructors

* `Web::Query->new($thing, \%options)` Builds a Web::Query object from a filename, a string of HTML, a URL, a [URI](https://metacpan.org/pod/URI) object, or an existing [HTML::Element](https://metacpan.org/pod/HTML::Element) (or array ref of them). Fetching a URL uses `LWP::UserAgent` internally; you can supply your own agent via `$Web::Query::UserAgent`.

* `Web::Query->new_from_url($url)` Like `new`, but specifically for URLs, and returns `undef` on a non-2xx response rather than throwing—check `Web::Query->last_response` for the failure detail.

### Traversing

* `$q->find($selector)` Returns a new object containing the descendants of the current set that match `$selector`—a CSS3 selector, or a scalar ref for a raw XPath expression. This is the method you'll use most.

* `$q->filter($selector)` Like `find`, but tests the elements in the current set themselves rather than their descendants.

* `$q->each($coderef)` Calls `$coderef` once per matched element, passing the index as the argument and localizing `$_` to a Web::Query object wrapping that single element—so you can call `find`/`text`/`attr` straight off `$_`, much like jQuery's `$(this)`.

* `$q->first`, `$q->last` Return a new object containing just the first or last matched element.

* `$q->parent`, `$q->next`, `$q->prev` Return the parent, next sibling, or previous sibling of each matched element.

* `$q->size` Returns the number of elements in the set.

### Reading and changing content

* `$q->text` Get the text content of the matched elements. In list context returns one string per element; in scalar context returns just the first.

* `$q->html` Get the inner HTML of the matched elements, following the same list/scalar convention as `text`.

* `$q->attr($name)`, `$q->attr($name => $value)` Get or set an attribute. Getting follows the same list/scalar convention as `text`; setting applies to every matched element and returns the object for chaining.

* `$q->as_html` Returns the matched elements themselves (not just their contents) as an HTML string.

XML::LibXML
-----------

[XML::LibXML](https://metacpan.org/pod/XML::LibXML) is a Perl binding
for `libxml2`. Unlike the older XML::Parser family, it builds a full
DOM and lets you query it with XPath in the same step.

### Constructors

* `XML::LibXML->load_xml(location => $filename)`, `XML::LibXML->load_xml(string => $xml)` Parse a document from a file or a string and return a document object. Throws an exception (rather than returning `undef`) on malformed XML—wrap the call in `eval` if you need to handle that gracefully.

### Methods (on a document or any node)

* `$doc->findvalue($xpath)` Runs an XPath expression and returns the text content of whatever it matches, as a plain string.

* `$doc->findnodes($xpath)` Runs an XPath expression and returns a list of matching element objects, which you can then query further.

* `$node->getAttribute($name)` Returns the value of the named attribute on an element.

* `$node->textContent` Returns all the text inside a node, with child elements' tags stripped out.

* `$node->nodeName` Returns the element's tag name.

* `$doc->documentElement` Returns the top-level (root) element of the document.

XML::LibXML also has a streaming reader,
[XML::LibXML::Reader](https://metacpan.org/pod/XML::LibXML::Reader),
for working through documents too large to hold as a DOM in memory all
at once.

JSON::MaybeXS
-------------

[JSON::MaybeXS](https://metacpan.org/pod/JSON::MaybeXS) picks the
fastest available JSON backend (`Cpanel::JSON::XS` if it's installed,
falling back to the pure-Perl `JSON::PP` otherwise) behind one
consistent interface. It gives you two ways to work, which handle
Unicode encoding differently—see [Chapter 5](ch009.xhtml) and
[Chapter 10](ch015.xhtml) for the full explanation.

### Functions (exported by default)

* `encode_json($data)`, `decode_json($json_bytes)` Convert a Perl data structure to JSON, or JSON bytes back to a data structure. These operate in *utf8 mode*: `encode_json` returns UTF-8 bytes, and `decode_json` expects UTF-8 bytes and hands back decoded characters.

### Object-oriented interface

* `JSON->new` Creates a JSON object, which can be configured by chaining methods before calling `encode`/`decode`.

* `->utf8` Switches the object into byte-mode: `encode` then returns UTF-8 bytes instead of a decoded Perl string, and `decode` expects bytes instead of a decoded string. Without this, the OO interface works with already-decoded characters—the opposite default to the plain functions above.

* `->pretty` Formats encoded output with indentation and newlines, for human-readable JSON.

* `->canonical` Sorts hash keys when encoding, so the same data structure always produces byte-identical output—useful for diffs and tests.

* `->encode($data)`, `->decode($json)` Encode a Perl data structure to JSON, or decode JSON back to a data structure, using whatever options have been chained onto the object.

YAML::PP
--------

[YAML::PP](https://metacpan.org/pod/YAML::PP) is a modern, actively
maintained YAML processor (the older `YAML` and `YAML::Syck` modules
are both best avoided for new code—`YAML::Syck` in particular is no
longer maintained).

### Constructor

* `YAML::PP->new(%options)` Creates a YAML::PP object. Called with no options, it's ready to use for the common case of reading and writing plain data structures.

### Methods

* `$ypp->load_file($filename)` Reads and parses a YAML file, handling UTF-8 decoding for you, and returns the resulting Perl data structure (a reference, if the document's top level is a list or mapping).

* `$ypp->dump_file($filename, $data)` Writes a Perl data structure to a file as YAML, handling UTF-8 encoding for you.

* `$ypp->load_string($yaml_text)` Like `load_file`, but parses a string you've already read (and decoded) yourself rather than opening a file.

* `$ypp->dump_string($data)` Like `dump_file`, but returns the YAML as a (decoded) string rather than writing it to a file.

HTTP::Tiny
----------

[HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) is a small,
dependency-free HTTP client that's been part of core Perl since 5.14.
It's a good default for straightforward requests—reach for
`LWP::UserAgent` instead if you need cookies, redirects across
protocols, or other things HTTP::Tiny deliberately leaves out.

### Constructor

* `HTTP::Tiny->new(%options)` Creates a client object. Common options include `timeout` (seconds) and `agent` (the User-Agent string to send).

### Methods

* `$http->get($url)`, `$http->post($url, \%options)`, `$http->post_form($url, \%form_data)` Make a GET or POST request. All return a hash reference (see below); `post_form` encodes `\%form_data` as `application/x-www-form-urlencoded`.

* `$http->request($method, $url, \%options)` The general-purpose method the shortcuts above call internally—use it directly for other HTTP methods, or when you need to pass a request body or headers via `\%options`.

### The response hash

Every request method returns a hash reference with these keys:

* `success` True if the request was made and received an HTTP response in the 2xx range.

* `status`, `reason` The numeric HTTP status code and its text reason phrase.

* `content` The response body, as raw bytes—decode it yourself (with `decode_json`, an `:encoding` layer, or similar) if you need text.

* `headers` A hash reference of the response headers, lower-cased.

Regexp::Grammars
----------------

[Regexp::Grammars](https://metacpan.org/pod/Regexp::Grammars) lets you
build a recursive-descent parser out of an ordinary Perl regular
expression, extended with named rules. It isn't part of core Perl.

### Grammar syntax

* `<rule: Name> ... </rule>` (the closing tag is implied by the next `<rule:>` or the end of the grammar) Defines a rule named `Name`. The body is itself a regular expression, which can reference other rules.

* `<Name>` Inside a rule's body, matches the rule called `Name`.

* `<[Name]>` Matches `Name` and captures each match into an array, for a rule that can match more than once.

* `<[Name]>+ % $separator` Matches one or more repetitions of `Name`, separated by `$separator` (a literal, or another rule reference)—the separators themselves aren't captured.

* `<nocontext:>` Turns off Regexp::Grammars' default "context" tracking, which most grammars in this book don't need.

* `<debug: on>` (or `same`, `off`) Turns on step-by-step tracing of the parser's attempts to match, useful when a grammar isn't matching what you expect. Controlled per-grammar, unlike Parse::RecDescent's global `$::RD_TRACE`/`$::RD_HINT` variables.

* `<objrule: Class>`, `<objtoken: Class>` Like `<rule:>`/`<token:>`, but bless the resulting hash into `Class` instead of leaving it as a plain hash reference.

### Using a grammar

* `$text =~ $grammar` Matches `$text` (a string) against a compiled grammar (built with `qr{...}`, using the syntax above). Returns true/false like any other regex match.

* `%/` On a successful match, this special hash is populated with the full parse tree—there's no separate object to build or method to call to extract the result, unlike Parse::RecDescent.
