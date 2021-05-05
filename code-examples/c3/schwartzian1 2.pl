my @CDs_sorted_by_year = sort { $a->{year} <=> $b->{year} } @CDs;
my @CD_and_year = map { [$_->{year}, $_] } @CDs;
my @sorted_CD_and_year = sort { $a->[0] <=> $b->[0] } @CD_and_year;
my @CDs_sorted_by_year = map { $_->[1] } @sorted_CD_and_year;
