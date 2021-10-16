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

Date::Calc
----------

The most useful functions in Date::Calc include:

* `$days = Days_in_Month($year, $month)` Returns the number of days in the given month in the given year.

* `$days = Days_in_Year($year, $month)` Returns the number of days in the given year up to the end of the given month. Thus, `Days_in_Year(2000, 1)` returns 31, and `Days_in_Year(2000, 2)` returns 60.

* `$is_leap = leap_year($year)` Returns 1 if the given year is a leap year and 0 if it isn’t.

* `$is_data = check_date($year, $month, $day)` Checks whether or not the given combination of year, month, and day constitute a valid date. Therefore `check_date(2000, 2, 29)` returns true, but `check_date(2000, 2, 2001)` returns false.

* `$doy = Day_of_Year($year, $month, $day)` Takes a given date in the year and returns the number of the day in the year that the date falls. Therefore `Day_of_Year(1962, 9, 7)` prints 250 as September 7 was the 250th day of 1962.

* `$dow = Day_of_Week($year, $month, $day)` Returns the day of the week that the given date fell on. This will be 1 for Monday and 7 for Sunday. Therefore `Day_of_Week(1962, 9, 7)` returns 5 as September 7, 1962, was a Friday.

* `$week = Week_Number($year, $month, $day)` Returns the week number of the year that the given date falls in. Week one is defined as the week that January 4 falls in, so it is possible for the number to be zero. It is also possible for the week number to be 53.

* `($year, $month, $day) = Monday_of_Week($week, $year)` Returns the date of the first day (*i.e.*, Monday) of the given week in the given year.

* `($year, $month, $day) = Nth_Weekday_of_Month_Year($year, $month, $dow, $n)` Returns the *n*th week day in the given month in the given year. For example if you wanted to find the third Sunday (day seven of the week) in November 1999 you would call it as `Nth_Weekday_of_Month_Year(1999, 11, 7, 3)` which would return the November 21, 1999.

* `$days = Delta_Days($year1, $month1, $day1, $year2, $month2, $day2)` Calculates the number of days between the two given dates.

* `($days, $hours, $mins, $secs) = Delta_DHMS($year1, $month1,$day1, $hour1, $min1, $sec1, $year2, $month2, $day2, $hour2, $min2, $sec2)` Returns the number of days, hours, minutes, and seconds between the two given dates and times.

* `($year, $month, $day) = Add_Delta_Days($year, $month, $day, $days)` Adds the given number of days to the given date and returns the resulting date. If $days is negative then it is subtracted from the given date. There are other functions that allow you to add days, hours, minutes, and seconds (`Add_Delta_DHMS`) and years, months, and days (`Add_Delta_YMD`).

* `($year, $month, $day, $hour, $min, $sec, $doy, $dow, $dst) =System_Clock` Returns the same set of values as Perl’s own internal localtime function, except that the values have been converted into the values recognized by Date::Calc. Specifically, this means the ranges of the month and day of week have been shifted and the year has had 1900 added to it. There are also functions to get the current date (`Today`), time (`Now`) and date and time (`Today_and_Now`).

* `($year, $month, $day) = Easter_Sunday($year)` Calculates the date of Easter Sunday in the given year.

* `$month = Decode_Month($string)` Parses the string and attempts to recognize it as a valid month name. If a month is found then the corresponding month number is returned. There is a similar function (`Decode_Day_of_Week`) for working with days of the week.

* `$string = Date_to_Text($year, $month, $day)` Returns a string which is a textual representation of the data that was passed to the function. For example `Date_to_Text(1999, 12, 25)` returns Sat 25-Dec-1999. There is also a `Date_to_Text_Long` function which for the same input would return Saturday 25 December 1999. This is only a sample of the most useful functions in the module. In particular, I have ignored the multilanguage support in the module.

Date::Manip
-----------

This is a brief list of some of the more important functions in
Date::Manip.

* `$date=ParseDateString($string)` Takes a string and attempts to parse a valid date out of it. The function will handle just about all common date and time formats and many other surprising ones like “today,” “tomorrow,” or in “two weeks” on Friday. This function returns the date in a standardized format, which is YYYYMMDDHH:MM:SS. You can convert it into a more user-friendly format using the UnixDate function described below. This is the most useful function in the module and you should think about installing this module simply to get access to this functionality.

* `$date = UnixDate($date, $format)` Takes the given date (which can be in any format that is understood by `ParseDateString`) and formats it using the value of `$format`. The format string can handle any of the character sequences used by `POSIX::strftime`, but it defines a number of new sequences as well. These are all defined in the Date::Manip documentation.

* `$delta = ParseDelta($string)` As well as dates (which indicate a fixed point in time), Date::Manip deals with date *deltas*. These are a number of years, months, days, hours, minutes, or seconds that you can add or subtract from a date in order to get another date. This function attempts to recognize deltas in the string that is passed to it and returns a standardized delta in the format Y:M:W:D:H:MN:S. The function recognizes strings like +3Y 4M 2D to add three years, four months and two days. It also recognizes more colloquial terms like “ago” (e.g., 4 years ago) and “in” (e.g., in three weeks).

* `@dates = ParseRecur($recur, [$base, $start, $end, $flags])` Returns a list of dates for a recurring event. The rules that govern how the event recurs are defined in `$recur`. The syntax is a little complex, but it is based loosely on the syntax of a UNIX crontab file and is defined in detail in the Date::Manip documentation.

* `$diff = Date_Cmp($date1, $date2)` Compares two dates and returns the same values as Perl’s internal `cmp` and `<=>` operators do for strings and numbers respectively; *i.e.*, –1 if `$date < $date1`, 0 if `$date1 == $date2`, and 1 if `$date1 > $date2`. This means that this function can be used as a sort routine.

* `$d = DateCalc($d1, $d2)` Takes two dates (or two deltas or one of each) and performs an appropriate calculation with them. Two deltas yield a third delta; a date and a delta yield the result of applying the delta to the date; and two dates yield a delta which is the time between the two dates. There are additional parameters that give you finer control over the calculation.

* `$date = Date_GetPrev($date, $dow, $curr, $time)` Given a date, this function will calculate the previous occurrence of the given day of the week. If the given date falls on the given day of the week, then the behavior depends on the setting of the `$curr` flag. If $curr is non-zero then the current date is returned. If `$curr` is zero then the date a week earlier is returned. If the optional parameter `$time` is passed to the function, then the time in the returned date is set to that value. There is also a very similar `Date_GetNext` function.

* `$day = Date_DayOfWeek($month, $day, $year)` Returns the day of the week that the given date fell on (1 for Monday, 7 for Sunday). Note the nonstandard order of the arguments to this function.

* `$day = Date_DayOfYear($month, $day, $year)` Returns the day of the year (1 to 366) that the given date falls on. Note the nonstandard order of the arguments to this function.

* `$days = Date_DaysInYear($year)` Returns the number of days in the given year.

* `$days = Date_DaysInMonth($month, $year)` Returns the number of days in the given month in the given year.

* `$flag = Date_LeapYear($year)` Returns 1 if the given year is a leap year and 0 otherwise.

* `$day = Date_DaySuffix($day)` Calculates the suffix that should be applied to the day number and appends it to the number; *e.g.*, `Date_DaySuffix` returns “1st.” This only scratches the surface of what Date::Manip is capable of. In particular, it has very good support for working with business days and holidays and allows you to configure it to work with local holidays.

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

Here is a brief guide to the methods of the HTML::Parser object. As I
mentioned briefly in [Chapter 9](ch014.xhtml), this describes version
3.x of HTML::Parser. In older versions you had to subclass
HTML::Parser in order to do any useful work with it. Unfortunately, as
I write this, the version of HTML::Parser available from the
ActiveState module repository for use with ActivePerl is still a 2.x
version. For further detail on using an older version, see the
documentation that comes with the module.

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

XXX: Format table

	 Table A.1
	 **HTML::Parser** handlers
	 Handler
	 Called when …
	 declaration
	 an HTML DOCTYPE declaration is found
	 start
	 the start of an HTML tag is found
	 end
	 the end of an HTML tag is found
	 text
	 plain text is found
	 comment
	 an HTML comment is found
	 process
	 a processing instruction is found
	 Each of these handlers can be defined in two ways. Either you can pass
	details of
	 the handler to the new method or you can use the handler method after
	creating
	the parser object, but before parsing the document. Here are examples of
	both uses.
	 my $parser = HTML::Parser->new(start_h => [\&start,
	'tagname,attr']);
	 $parser->handler(start => [\&start, 'tagname,attr']);
	 In both examples we have set the start handler to be a function called
	start which
	must be defined somewhere within our program. The only difference
	between the
	two versions is that when using new, the event name (i.e., start) must
	have the
	string _h appended to it. In both examples the actual subroutine to be
	called is
	 defined in a two-element array. The first element of the array is a
	reference to the
	subroutine to be called and the second element is a string defining the
	arguments
	which the subroutine expects. The various values that this string can
	contain are
	listed in table A.2.
	 Table A.2
	 Argument specification strings
	 Name
	 Description
	 Data type
	 self
	 The current parser object
	 Reference to the object
	 tokens
	 The list of tokens which makes up the current event
	 Reference to an array
	 tokenpos
	 A list of the positions of the tokens in the original text. Each token
	 Reference to an array
	 has two numbers; the first is the offset of the start of the token,
	and the second is the length of the token.
	 token0
	 The text of the first token (this is the same as $tokens->[0])
	 Scalar value
	 tagname
	 The name of the current tag
	 Scalar value
	 attr
	 The name and values of the attributes of the current tag
	 Reference to a hash
	 attrseq
	 A list of the names of the attributes of the current tag in the order
	 Reference to an array
	 that they appear in the original document
	 text
	 The source text for this event
	 Scalar value
	 dtest
	 The same as “text” but with any HTML entities (e.g., &amp;) decoded
	 Scalar value
	 is_cdata
	 True if event is in a CDATA section
	 Scalar value
	 offset
	 The offset (in bytes) of the start of the current event from the start
	 Scalar value
	 of the HTML document
	 length
	 Length (in bytes) of the original text which constitutes the event
	 Scalar value
	 event
	 The name of the current event
	 Scalar value
	 line
	 The number of the line in the document where this event started
	 Scalar value
	 ' '
	 Any literal string is passed to the handler unchanged
	 Scalar value
	 undef
	 An undef value
	 Scalar value

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

XML::Parser
-----------

XML::Parser is one of the most complex modules that is covered in this
book. Here is a brief reference to its most commonly used methods.

* `$parser = XML::Parser->new(Style => $style, Handlers => \%handlers, Pkg => $package)` Creates an XML::Parser object. It takes a number of optional named parameters. The Style parameter indicates which of a number of canned parsing styles you would like to use. Table A.3 lists the available styles along with the results of choosing a particular style.

XXX Format table

	 Table A.3
	 **XML::Parser** Styles
	 Style
	 Results
	 name
	 Debug
	 Prints out a stylized version of the document outline.
	 Subs
	 When the start of an XML tag is found, the parser calls a subroutine
	with the same name as
	the tag. When the end of an XML tag is found, the parser calls a
	subroutine with the same
	names as the tag with an underscore character prepended. Both of these
	subroutines are
	presumed to exist in the package denoted by the Pkg parameter. The
	parameters passed to
	these subroutines are the same as those passed to the Start and End
	handler routines.


	 Table A.3
	 **XML::Parser** Styles (continued)
	 Style
	 Results
	 name
	 Tree
	 The parse method will return a parse tree representing the document.
	Each node is repre-
	sented by a reference to a two-element array. The first element in the
	list is either the tag
	name or “0” if it is a text node. The second element is the content of
	the tag. The content is
	a reference to another array. The first element of this array is a
	reference to a (possibly empty)
	hash containing attribute/value pairs. The rest of this array is made up
	of pair of elements
	representing the type and content of the contained nodes. See section
	9.2.3 for examples.
	 Objects
	 The parse method returns a parse tree representing the object. Each
	node in the tree is a
	hash which has been blessed into an object. The object type names are
	created by append-
	ing the type of each tag to the value of the Pkg parameter followed by
	::. A text node is
	blessed into the class ::Characters. Each node will have a kids
	attribute which will be a
	reference to an array containing each of the node’s children.
	 Stream
	 This style works in a manner similar to the Subs style. Whenever the
	parser finds particular
	XML objects, it calls various subroutines. These subroutines are all
	assumed to exist in the
	package denoted by the Pkg parameter. The subroutines are called
	StartDocument,
	 StartTag, EndTag, Text, PI, and EndDocument. The only one of these
	names which
	doesn’t make it obvious when the subroutine is called is PI. This is
	called when the parser
	encounters a processing instruction in the document.

The Handlers parameter is a reference to a hash. The keys of this
hash are the names of the events that the parser triggers while
parsing the document and the values are references to subroutines
which are called when the events are triggered. The subroutines are
assumed to be in the package defined by the `Pkg` parameter. Table A.4
lists the various types of handlers. The first parameter to each of
these handlers is a reference to the Expat object which XML::Parser
creates to actually handle the parsing. This object has a number of
its own methods which you can use to gain even more precise control
over the parsing process. For details of these, see the manual page
for XML::Parser::Expat.

XXX: Format Table

	 Table A.4
	 **XML::Parser** Handlers
	 Handler
	 When called
	 Subroutine parameters
	 Init
	 Before the parser starts processing the document
	 Reference to the Expat object
	 Final
	 After the parser finishes processing the document
	 Reference to the Expat object
	 Start
	 When the parser finds the start of a tag
	 Reference to the Expat object
	Name of the tag found
	List of name/value pairs for
	the attributes


	 Table A.4
	 **XML::Parser** Handlers (continued)
	 Handler
	 When called
	 Subroutine parameters
	 End
	 When the parser finds the end of a tag
	 Reference to the Expat Object
	 Char
	 When the parser finds character data
	 Reference to the Expat Object
	The character string
	 Proc
	 When the parser finds a processing instruction
	 Reference to the Expat Object
	The name of the PI target
	The PI data
	 Comment
	 When the parser finds a comment
	 Reference to the Expat Object
	The comment data
	 CdataStart
	 When the parser finds the start of a CDATA section
	 Reference to the Expat Object
	 CdataEnd
	 When the parser finds the end of a CDATA section
	 Reference to the Expat Object
	 Default
	 When the parser finds any data that doesn’t have an Reference to the
	Expat Object
	assigned handler
	 The data string
	 Unparsed
	 When the parser finds an unparsed entity declaration
	 Reference to the Expat Object
	Name of the Entity
	Base URL to use when resolving the
	address
	The system ID
	The public ID
	 Notation
	 When the parser finds a notation declaration
	 Reference to the Expat Object
	Name of the Notation
	Base URL to use when resolving the
	address
	The system ID
	The public ID
	 ExternEnt
	 When the parser finds an external entity declaration
	 Reference to the Expat Object.
	Base URL to use when resolving the
	address
	The system ID.
	The public ID.
	 Entity
	 When the parser finds an entity declaration
	 Reference to the Expat Object
	Name of the Entity
	The value of the Entity
	The system ID
	The public ID
	The notation for the entity
	 Element
	 When the parser finds an element declaration
	 Reference to the Expat Object
	Name of the Element
	The Content Model


	 Table A.4
	 **XML::Parser** Handlers (continued)
	 Handler
	 When called
	 Subroutine parameters
	 Attlist
	 When the parser finds an attribute declaration
	 Reference to the Expat Object
	Name of the Element
	Name of the Attribute
	The Attribute Type
	Default Value
	String indicating whether the
	attribute is fixed
	 Doctype
	 When the parser finds a DocType declaration
	 Reference to the Expat Object
	Name of the Document Type
	System ID
	Public ID
	The Internal Subset
	 XMLDecl
	 When the parser finds an XML declaration
	 Reference to the Expat Object
	Version of XML
	Document Encoding
	String indication whether or not the
	DTD is standalone

`Pkg` is the name of a package. All handlers are assumed to be in this
package and all styles which rely on user-defined subroutines also
search for them in this package. If this parameter is not given then
the default package name is `main`.

This method also takes a number of other optional parameters, all of
which are passed straight on to the Expat object. For details see the
manual page for XML::Parser.

* `$parser->parse($source)` Parses the document. The $source parameter
should either be the entire document in a scalar variable or a
reference to an open IO::Handle object. The return value varies
depending on the style chosen.

* `$parser->parse_file($filename)` Opens the given file and parses the
contents. The return value varies according to the style chosen.

* `$parser->setHandlers(%handlers)` Overrides the current set of
handlers with a new set. The parameters are interpreted as a hash in
exactly the same format as the one passed to new. By including an
empty string or `undef`, the associated handler can be switched off.
