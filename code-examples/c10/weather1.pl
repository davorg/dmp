use strict; 

use XML::Parser; 

my %forecast; 
my @curr; 
my $type; 

my $p = XML::Parser->new(Style => 'Stream'); 

$p->parsefile(shift); 
print "Outlook: $forecast{outlook}\n"; 

foreach (keys %forecast) { 
  next if /outlook/; 
  print "$_: $forecast{$_}->{val} $forecast{$_}->{deg}\n"; 
} 

sub StartTag { 
  my ($p, $tag) = @_; 

  push @curr, $tag; 

  if ($tag eq 'TEMPERATURE') { 
    $type = $_{TYPE}; 
    $forecast{$type}->{deg} = $_{DEGREES};
  } 
} 

sub EndTag { 
  pop @curr; 
}; 

sub Text { 
  my ($p) = shift; 
  return unless /\S/; 

  s/^\s+//; 
  s/\s+$//; 

  if ($curr[-1] eq 'OUTLOOK') { 
    $forecast{outlook} .= $_; 
  } elsif ( $curr[-1] eq 'TEMPERATURE') { 
    $forecast{$type}->{val} = $_; 
  } 
}
