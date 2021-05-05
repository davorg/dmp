my %data;

chomp($data{title} = <STDIN>); 
chomp($data{date} = <STDIN>);
<STDIN>;
my ($labels, @labels);
chomp($labels = <STDIN>);
@labels = split(/\s+/, $labels);
<STDIN>;

my $template = 'A14 A19 A15 A8'; 

my %rec; 
while (<STDIN>) { 
  chomp; 

  last if /^\s*$/; 

  if (/^\+/) {
    push @{$rec{tracks}}, substr($_, 1); 
  } else {
    push @{$data{CDs}}, {%rec} if keys %rec;
    %rec = ();
    @rec{@labels} = unpack($template, $_);
  }
} 

push @{$data{CDs}}, {%rec} if keys %rec; 

($data{count}) = (<STDIN> =~ /(\d+)/);

if ($data{count} == @{$data{CDs}}) {
  print "$data{count} records processed successfully\n";
} else {
  warn "Expected $data{count} records but received ",
  scalar @{$data{CDs}}, "\n"; 
}
