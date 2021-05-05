#!/usr/local/bin/perl -w 

use strict; 
use DBI; 

my $user = 'dave'; 
my $pass = 'secret'; 
my $dbh = DBI->connect('dbi:mysql:testdb', $user, $pass, 
		       {RaiseError => 1}) 
  || die "Connect failed: $DBI::errstr";

my $sth = $dbh->prepare('select col1, col2, col3 from my_table');

$sth->execute;

my @row;
while (@row = $sth->fetchrow_array) { 
  print join("\t", @row), "\n";
} 

$sth->finish;
$dbh->disconnect;
