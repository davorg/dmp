use LWP::Simple; 

my $page = get('http://www.mag-sol.com/index.html');
getprint('http://www.mag-sol.com/index.html');
getstore('http://www.mag-sol.com/index.html', 'index.html');
