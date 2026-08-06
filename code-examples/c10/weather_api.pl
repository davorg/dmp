use v5.40;
use HTTP::Tiny;
use JSON::MaybeXS;

my %description = (
    0 => 'Clear sky',        1 => 'Mainly clear',
    2 => 'Partly cloudy',    3 => 'Overcast',
    45 => 'Fog',             48 => 'Depositing rime fog',
    51 => 'Light drizzle',   53 => 'Moderate drizzle',
    55 => 'Dense drizzle',   61 => 'Slight rain',
    63 => 'Moderate rain',   65 => 'Heavy rain',
    71 => 'Slight snow',     73 => 'Moderate snow',
    75 => 'Heavy snow',      80 => 'Rain showers',
    95 => 'Thunderstorm',
);

my ($lat, $lon) = (51.5072, -0.1276);   # Central London
my $url = 'https://api.open-meteo.com/v1/forecast'
    . "?latitude=$lat&longitude=$lon"
    . '&current=temperature_2m,weather_code'
    . '&daily=temperature_2m_max,temperature_2m_min,weather_code'
    . '&timezone=Europe%2FLondon';

my $res = HTTP::Tiny->new->get($url);
die "Request failed: $res->{status} $res->{reason}\n" unless $res->{success};

my $forecast = decode_json($res->{content});

my $now = $forecast->{current};
say "Now: $description{$now->{weather_code}}, $now->{temperature_2m}C";

my $today = $forecast->{daily};
say "Today: $description{$today->{weather_code}[0]}, "
  . "$today->{temperature_2m_min}[0]C to $today->{temperature_2m_max}[0]C";
