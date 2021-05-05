# Variables to keep track of where we are in the file 
my ($line, $word);

# Variables to store stats 
my ($num_lines, $num_words); 
my (%words, %lengths);

my $text = read_text(); 

$num_lines = scalar @{$text}; 

foreach $line (@{$text}) { 
  $num_words += scalar @{$line};

  foreach $word (@{$line}) {
    $words{$word}++;
    $lengths{length $word}++; 
  }
} 

my @sorted_words = sort { $words{$b} <=> $words{$a} } keys %words;
my @sorted_lengths = sort { $lengths{$b} <=> $lengths{$a} } keys %lengths;

print "Your file contains $num_lines lines "; 
print "and $num_words words\n\n"; 

print "The 5 most popular words were:\n";
print map { "$_ ($words{$_} times)\n" } @sorted_words[0 .. 4]; 

print "\nThe 5 most popular word lengths were:\n"; 
print map { "$_ ($lengths{$_} words)\n" } @sorted_lengths[0 .. 4];
