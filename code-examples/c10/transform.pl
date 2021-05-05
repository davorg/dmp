#!/usr/bin/perl -w 

use strict; 

use XML::Parser; 
use Getopt::Std;
use Text::Wrap; 

my %formats = (h => {name => 'html'}, 
	       p => {name => 'pod'}, 
	       t => {name => 'text'}); 

my %opts; 
(getopts('f:', \%opts) && @ARGV) 
  || die "usage: format_xml.pl -f h|p|t xml_file\n"; 

die "Invalid format: $opts{f}\n" unless exists $formats{$opts{f}}; 

warn "Formatting file as $formats{$opts{f}}->{name}\n"; 

my $p = XML::Parser->new(Style => 'Tree'); 
my $tree = $p->parsefile(shift); 

my $level = 0; 
my $ind = ''; 
my $head = 1; 

top($tree); 

process_node(@$tree); 

bot(); 

sub process_node { 
  my ($type, $content) = @_; 

  $ind = ' ' x $level; 

  if ($type) { 
    local $_ = $type; 

    my $attrs = shift @$content; 

    /^NAME$/ && name($content); 
    /^SYNOPSIS$/ && synopsis($content); 
    /^DESCRIPTION$/ && description(); 
    /^TEXT$/ && text($content); 
    /^CODE$/ && code($content); 
    /^HEAD$/ && head($content); 
    /^LIST$/ && do {list($attrs, $content); @$content = ()}; 
    /^AUTHOR$/ && author(); 
    /^ANAME$/ && aname($content); 
    /^EMAIL$/ && email($content); 
    /^SEE_ALSO$/ && see_also($content); 

    while (my @node = splice @$content, 0, 2) { 
      ++$level; 
      ++$head if $type eq 'SUBSECTION'; 
      process_node(@node); 
      --$head if $type eq 'SUBSECTION'; 
      --$level; 
    } 
  } 
} 

sub top { 
  $tree = shift; 
  
  if ($opts{f} eq 'h') { 
    print "<html>\n";
    print "<head>\n"; 
    print "<title>$tree->[1]->[4]->[2]</title>\n"; 
    print "</head>\n<body>\n"; 
  } elsif ($opts{f} eq 'p') { 
    print "=pod\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print "\n", $tree->[1]->[4]->[2], "\n"; 
    print '-' x length($tree->[1]->[4]->[2]), "\n\n"; 
  } 
} 

sub bot { 
  if ($opts{f} eq 'h') { 
    print "</body>\n</html>\n"; 
  } elsif ($opts{f} eq 'p') { 
    print "=cut\n\n"; 
  } elsif ($opts{f} eq 't') { 
    # do nothing 
  } 
} 

sub name { 
  my $content = shift; 

  if ($opts{f} eq 'h') { 
    print "<h1>NAME</h1>\n"; 
    print "<p>$content->[1]</p>\n" 
  } elsif ($opts{f} eq 'p') { 
    print "=head1 NAME\n\n"; 
    print "$content->[1]\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print "NAME\n\n"; 
    print $ind, "$content->[1]\n\n"; 
  }
}

sub synopsis { 
  my $content = shift; 

  if ($opts{f} eq 'h') { 
    print "<h1>SYNOPSIS</h1>\n"; 
    print "<pre>$content->[1]</pre>\n";
  } elsif ($opts{f} eq 'p') { 
    print "=head1 SYNOPSIS\n\n"; 
    print "$content->[1]\n"; 
  } elsif ($opts{f} eq 't') { 
    print "SYNOPSIS\n"; 
    print "$content->[1]\n"; 
  } 
} 
  
sub description { 
  if ($opts{f} eq 'h') { 
    print "<h1>DESCRIPTION</h1>\n"; 
  } elsif ($opts{f} eq 'p') { 
    print "=head1 DESCRIPTION\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print "DESCRIPTION\n\n"; 
  } 
} 

sub text { 
  my $content = shift; 

  if ($opts{f} eq 'h') { 
    print "<p>$content->[1]</p>\n";
  } elsif ($opts{f} eq 'p') { 
    print wrap('', '', trim($content->[1])), "\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print wrap($ind, $ind, trim($content->[1])), "\n\n"; 
  } 
} 

sub code { 
  my $content = shift; 
  
  if ($opts{f} eq 'h') { 
    print "<pre>$content->[1]</pre>\n";
  } elsif ($opts{f} eq 'p') {
    print "$content->[1]\n"; 
  } elsif ($opts{f} eq 't') {
    print "$content->[1]\n";
  } 
}

sub head { 
  my $content = shift; 

  if ($opts{f} eq 'h') {
    print "<h$head>", trim($content->[1]), "</h$head>\n" 
  } elsif ($opts{f} eq 'p') { 
    print "=head$head ", trim($content->[1]), "\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print trim($content->[1]), "\n\n"; 
  } 
} 

sub list { 
  my ($attrs, $content) = @_; 

  my %list = (bullet => 'ul', numbered => 'ol');

  my $type = $attrs->{TYPE}; 

  if ($opts{f} eq 'h') { 
    print "<$list{$type}>\n"; 
    while (my @node = splice @$content, 0, 2) { 
      if ($node[0] eq 'ITEM') { 
	print "<li>$node[1]->[2]</li>\n"; 
      } 
    } 
    print "</$list{$type}>\n"; 
  } elsif ($opts{f} eq 'p') { 
    print "=over 4\n"; 
    while (my @node = splice @$content, 0, 2) { 
      my $cnt = 1; 
      if ($node[0] eq 'ITEM') { 
	print "=item *\n$node[1]->[2]\n\n"; 
      } 
    } 
    print "=back\n\n"; 
  } elsif ($opts{f} eq 't') { 
    while (my @node = splice @$content, 0, 2) { 
      my $cnt = 1; 
      if ($node[0] eq 'ITEM') { 
	print $ind, "* $node[1]->[2]\n"; 
      } 
    } 
    print "\n"; 
  } 
} 

sub author { 
  if ($opts{f} eq 'h') { 
    print "<h1>AUTHOR</h1>\n";
  } elsif ($opts{f} eq 'p') { 
    print "=head1 AUTHOR\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print "AUTHOR\n\n"; 
  } 
} 

sub aname { 
  my $content = shift; 

  if ($opts{f} eq 'h') {
    print "<p>$content->[1]\n" 
  } elsif ($opts{f} eq 'p') { 
    print trim($content->[1]), ' '; 
  } elsif ($opts{f} eq 't') { 
    print $ind, trim($content->[1]), ' '; 
  }
} 

sub email { 
  my $content = shift; 

  if ($opts{f} eq 'h') { 
    print '&lt;', trim($content->[1]), "&gt;</p>\n" 
  } elsif ($opts{f} eq 'p') { 
    print '<', trim($content->[1]), ">\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print '<', trim($content->[1]), ">\n\n"; 
  } 
} 

sub see_also { 
  if ($opts{f} eq 'h') { 
    print "<h1>SEE ALSO</h1>\n"; 
  } elsif ($opts{f} eq 'p') { 
    print "=head1 SEE ALSO\n\n"; 
  } elsif ($opts{f} eq 't') { 
    print "SEE ALSO\n\n"; 
  } 
} 

sub trim { 
  local $_ = shift; 

  s/\n/ /g; 
  s/^\s+//; 
  s/\s+$//; 
  
  $_; 
}
