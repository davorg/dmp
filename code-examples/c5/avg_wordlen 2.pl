my ($total_length, $num_words); 

my $text = read_text();

my ($word, $line); 
foreach $line (@{$text}) { 
  $num_words += scalar @{$line}; 
  foreach $word (@{$line}) { 
    $total_length += length $word; 
  } 
} 

printf "The average word length is %.2f\n", $total_length / $num_words;
