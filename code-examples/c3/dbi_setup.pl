use v5.36;
use DBI;

# Creates testdb.db and fills a "cds" table from cd.txt, ready for dbi.pl

my $dbh = DBI->connect('dbi:SQLite:dbname=testdb.db', undef, undef,
                       { RaiseError => 1, AutoCommit => 1 })
  or die "Connect failed: $DBI::errstr";

$dbh->do('drop table if exists cds');
$dbh->do('create table cds (artist text, title text, label text, year integer)');

my $insert = $dbh->prepare('insert into cds values (?, ?, ?, ?)');

open my $fh, '<:encoding(UTF-8)', 'cd.txt' or die "Can't open cd.txt: $!";

$dbh->begin_work;
while (my $line = <$fh>) {
  chomp $line;
  $insert->execute(split /\t/, $line);
}
$dbh->commit;

say 'Loaded ', $dbh->selectrow_array('select count(*) from cds'), ' CDs into testdb.db';
