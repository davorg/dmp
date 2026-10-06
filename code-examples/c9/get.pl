use LWP::Simple; 

my $page = get('http://example.com/');
getprint('http://example.com/');
getstore('http://example.com/', 'example.html');
