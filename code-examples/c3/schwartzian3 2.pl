print map { $_->[0] } 
      sort { $a->[1] cmp $b->[1] } 
      map { [$_, (split /\t/)[2]] } <STDIN>;
