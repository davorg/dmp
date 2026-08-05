open my $mail_fh, '<', 'mail.txt' or die "Can't open mail.txt: $!"; 

while (<$mail_fh>) { 
  if (/^([^:]+): ?(.+)$/) { 
    print "Header $1 has the value $2\n"; 
  }
}
