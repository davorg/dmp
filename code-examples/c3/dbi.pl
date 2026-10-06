#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dbh = DBI->connect('dbi:SQLite:dbname=testdb.db', undef, undef,
                       {RaiseError => 1})
  or die "Connect failed: $DBI::errstr";

my $sth = $dbh->prepare('select artist, title, year from cds order by artist, year');

$sth->execute;

my @row;
while (@row = $sth->fetchrow_array) {
  print join("\t", @row), "\n";
}

$sth->finish;
$dbh->disconnect;
