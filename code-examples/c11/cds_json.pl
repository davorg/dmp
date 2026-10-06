use v5.40;

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
        .{17}

    <rule: TitleField>
        .{23}

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

Artist           Title                  Label          Released
---------------------------------------------------------------
Allen, Lily      It's Not Me, It's You  Regal          2009
+The Fear
+22
Allen, Lily      West End Girl          BMG            2025
+West End Girl
+Madeline
Bowie, David     The Next Day           Columbia       2013
+Where Are We Now?
+Valentine's Day
Bowie, David     Blackstar              Columbia       2016
+Lazarus
+Girl Loves Me
LCD Soundsystem  Sound of Silver        EMI            2007
+Someone Great
+North American Scum
LCD Soundsystem  This Is Happening      Parlophone     2010
+I Can Change
+Drunk Girls
6 Records

