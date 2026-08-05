use strict;
use warnings;

use builtin qw(trim);
no warnings 'experimental::builtin';

use Regexp::Grammars;
use Data::Dumper;

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

    my %output = (
        title => $data->{File}{Header}{Title},
        date  => $data->{File}{Header}{Date},
        count => $data->{File}{Footer}{Count},
        list  => [],
    );

    for my $cd (@{ $data->{File}{Body}{CD} }) {
        push @{ $output{list} }, {
            artist   => trim($cd->{CDLine}{Artist}),
            title    => trim($cd->{CDLine}{TitleField}),
            label    => trim($cd->{CDLine}{Label}),
            released => $cd->{CDLine}{Released},
            tracks   => [ map { $_->{Track} } @{ $cd->{TrackLine} || [] } ],
        };
    }

    print Dumper(\%output);
} else {
    print "Parse failed\n";
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
6 Records

