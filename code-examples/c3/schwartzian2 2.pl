my @CDs_sorted_by_year = map { $_->[0] } 
                         sort { $a->[1] <=> $b->[1] } 
                         map { [$_, $_->{year}] } @CDs;
