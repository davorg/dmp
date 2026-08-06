use v5.40;
use HTTP::Tiny;
use JSON::MaybeXS;
use YAML::PP;

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

my $cities = YAML::PP->new->load_file('cities.yaml');

for my $city (@$cities) {
    my $url = 'https://api.open-meteo.com/v1/forecast'
        . "?latitude=$city->{latitude}&longitude=$city->{longitude}"
        . '&current=temperature_2m,weather_code';

    my $res = HTTP::Tiny->new->get($url);
    next unless $res->{success};

    my $now = decode_json($res->{content})->{current};
    say "$city->{name}: $description{$now->{weather_code}}, "
      . "$now->{temperature_2m}C";
}
