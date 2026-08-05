open my $mail_fh, '<', 'mail.txt' or die "Can t open mail.txt: $!"; 

while (<$mail_fh>) { 
  print if m/^From:/; 
}
