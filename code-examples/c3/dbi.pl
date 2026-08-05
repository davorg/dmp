#!/usr/local/bin/perl 

use strict; 
use warnings;
use feature 'say';
use DBI; 

my $user = 'dave'; 
my $pass = 'secret'; 
my $dbh = DBI->connect('dbi:mysql:testdb', $user, $pass, 
		       {RaiseError => 1}) 
  or die "Connect failed: $DBI::errstr";

my $sth = $dbh->prepare('select col1, col2, col3 from my_table');

$sth->execute;

my @row;
while (@row = $sth->fetchrow_array) { 
  say join "\t", @row;
} 

$sth->finish;
$dbh->disconnect;
