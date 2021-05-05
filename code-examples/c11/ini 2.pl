use Parse::RecDescent; 

my $grammar = q(file: section(s) 
		{ 
		  my %file; 
		  foreach (@{$item[1]}) { 
		    $file{$_->[0]} = $_->[1]; 
		  } 
		  \%file; 
		} 

	        section: header assign(s) 
		{ 
		  my %sec; 
		  foreach (@{$item[2]}) { 
		    $sec{$_->[0]} = $_->[1]; 
		  } 
		  [ $item[1], \%sec] 
		} 

	        header: '[' /\w+/ ']' 
		{ 
		 $item[2] 
		} 

	        assign: /\w+/ '=' /\w+/ 
		{ 
		 [$item[1], $item[3]] 
		}); 

$parser = Parse::RecDescent->new($grammar); 
my $text; 

{ 
  $/ = undef; 
  $text = <STDIN>; 
} 

my $tree = $parser->file($text); 
foreach (keys %$tree) { 
  print "$_\n"; 
  foreach my $key (keys %{$tree->{$_}}) { 
    print "\t$key: $tree->{$_}{$key}\n"; 
  } 
}
