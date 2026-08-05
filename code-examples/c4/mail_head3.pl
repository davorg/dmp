open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!"; 

my ($header, $value); 
while (<$mail_fh>) { 
  if (($header, $value) = /^([^:]+): ?(.+)$/) { 
    print "Header $header has the value $value\n"; 
  }
}
