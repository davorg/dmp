use strict;

use Parse::RecDescent;
use Data::Dumper;

use vars qw(@cols);

my $grammar = q(file: header body footer
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

	        footer: /\d+/ 'Records' { { count => $item[1] } } );

my $parser = Parse::RecDescent->new($grammar);

my $text;

{
  local $/ = undef;
  $text = <DATA>;
}

my $CDs = $parser->file($text);
print Dumper($CDs);
