use v5.36;
use List::Util qw(max);
use Time::Piece;

my (%by_day, %by_hour);

while (my $line = <STDIN>) {
  chomp $line;
  next unless length $line;
  my ($date, $subject) = split /\t/, $line, 2;

  # git's "iso" dates look like 2026-10-06 14:28:01 +0100. Time::Piece reads
  # the offset (%z) and converts the time to UTC...
  my $when = eval { Time::Piece->strptime($date, '%Y-%m-%d %H:%M:%S %z') }
    or do { warn "Skipping odd date '$date'\n"; next };

  # ...so turn it back into a time on this machine's clock
  my $local = localtime($when->epoch);

  $by_day{ $local->wdayname }++;
  $by_hour{ $local->hour }++;
}

# Scale the bars so that a big repository doesn't run off the screen
sub bar($count, $biggest) {
  my $scale = $biggest > 50 ? $biggest / 50 : 1;
  return '#' x int($count / $scale + 0.5);
}

say 'Commits by day of the week';
my $biggest = max(values %by_day);
for my $day (qw(Mon Tue Wed Thu Fri Sat Sun)) {
  my $n = $by_day{$day} // 0;
  printf "%s %4d %s\n", $day, $n, bar($n, $biggest);
}

say '';
say 'Commits by hour of the day';
$biggest = max(values %by_hour);
for my $hour (0 .. 23) {
  my $n = $by_hour{$hour} // 0;
  printf "%02d:00 %4d %s\n", $hour, $n, bar($n, $biggest);
}

say '';
say 'Busiest five hours';
my @busiest = (sort { $by_hour{$b} <=> $by_hour{$a} || $a <=> $b } keys %by_hour)[0 .. 4];
printf "%02d:00 %4d\n", $_, $by_hour{$_} for @busiest;
