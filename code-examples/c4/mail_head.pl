open MAIL, 'mail.txt' or die "Can t open mail.txt: $!"; 

while (<MAIL>) { 
  print if m/^From:/; 
}
