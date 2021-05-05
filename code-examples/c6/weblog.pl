use Logfile::Apache;

my $log = Logfile::Apache->new(File => 'access_log', 
			       Group => [qw(Host Date File Bytes User)]);
$log->report(Group => 'File');

$log->report(Group => 'File', Sort => 'Records', Top => 10);

$log->report(Group => 'Hour');

$log->report(Group => 'Hour', Sort => 'Records');

$log->report(Group => 'Hour', Sort => 'Records', Reverse => 1);
