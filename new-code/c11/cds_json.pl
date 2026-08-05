use v5.40;
use builtin qw(trim);
use feature 'signatures';
no warnings 'experimental::signatures';

use Regexp::Grammars;
use JSON::MaybeXS;

my $grammar = qr{
    \A
    <File>
    \Z

    <nocontext:>

    <rule: File>
        <Header>
        <Body>
        <Footer>

    <rule: Header>
        <Title> \n
        <Date> \n

    <rule: Title>
        [^\n]+

    <rule: Date>
        \d+\s+\w+\s+\d{4}

    <rule: Body>
        <ColHeads>
        <Divider>
        <[CD]>+

    <rule: ColHeads>
        <[ColName]>+ %\s+ \n

    <rule: ColName>
        \w+

    <rule: Divider>
        -+ \n

    <rule: CD>
        <CDLine>
        <[TrackLine]>*

    <rule: CDLine>
        <Artist> <TitleField> <Label> <Released> \n

    <rule: Artist>
        .{14}

    <rule: TitleField>
        .{19}

    <rule: Label>
        .{15}

    <rule: Released>
        \d{4}

    <rule: TrackLine>
        \+ <Track> \n

    <rule: Track>
        [^\n]+

    <rule: Footer>
        <Count> \s+ Records \n?

    <rule: Count>
        \d+
}x;

local $/ = undef;
my $text = <DATA>;

if ($text =~ $grammar) {
    my $data = \%/;

    my $output = {
        title => $data->{File}{Header}{Title},
        date  => $data->{File}{Header}{Date},
        count => $data->{File}{Footer}{Count},
        list  => [ map { cd_record($_) } $data->{File}{Body}{CD}->@* ],
    };

    say JSON->new->utf8->pretty->encode($output);
} else {
    say "Parse failed";
}

sub cd_record ($cd) {
    return {
        artist   => trim($cd->{CDLine}{Artist}),
        title    => trim($cd->{CDLine}{TitleField}),
        label    => trim($cd->{CDLine}{Label}),
        released => $cd->{CDLine}{Released},
        tracks   => [ map { $_->{Track} } $cd->{TrackLine}->@* ],
    };
}

__DATA__
Dave's CD Collection
16 Sep 1999

Artist        Title              Label          Released
--------------------------------------------------------
Bragg, Billy  Workers' Playtime  Cooking Vinyl  1988
+She's Got A New Spell
+Must I Paint You A Picture
Bragg, Billy  Mermaid Avenue     EMI            1998
+Walt Whitman's Niece
+California Stars
Black, Mary   The Holy Ground    Grapevine      1993
+Summer Sent You
+Flesh And Blood
Black, Mary   Circus             Grapevine      1995
+The Circus
+In A Dream
Bowie, David  Hunky Dory         RCA            1971
+Changes
+Oh You Pretty Things
Bowie, David  Earthling          EMI            1997
+Little Wonder
+Looking For Satellites
7 Records

