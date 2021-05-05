use strict; 
use XML::Parser; 

my $p = XML::Parser->new(Handlers => {Init => \&init, 
				      Start => \&start, 
				      End => \&end, 
				      Char => \&char}); 

my ($level, $ind);
my $text; 

$p->parsefile(shift); 

sub init { 
  $level = 0; $text = ''; 
} 

sub start { 
  my ($p, $tag) = (shift, shift); 
  my %attrs = @_ if @_; 

  print $ind, $tag, ' ['; 
  print join ', ', map { "$_: $attrs{$_}" } keys %attrs; 
  print "]\n"; 

  $level++;
  $ind =' ' x $level; 
} 

sub end { 
  print $ind, $text, "\n"; 

  $level--; 
  $ind =' ' x $level; 
  $text = ''; 
} 

sub char { 
  my ($p, $str) = (shift, shift); 
  return unless $str =~ /\S/; 

  $str =~ s/^\s+//; 
  $str =~ s/\s+$//; 
  $text .= $str; 
}
