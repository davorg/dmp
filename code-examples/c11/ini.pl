use v5.40;

use Regexp::Grammars;
use JSON::MaybeXS;

my $grammar = qr{
    \A <File> \Z

    <nocontext:>

    <rule: File>
        <[Section]>+

    <rule: Section>
        <Header> \s* \n
        <[Assign]>*

    <rule: Header>
        \[ <Name> \]

    <rule: Name>
        \w+

    <rule: Assign>
        \s* <Key> \s* = \s* <Value> \s* \n?

    <rule: Key>
        \w+

    <rule: Value>
        [^\n\r]+
}x;

local $/ = undef;
my $text = <STDIN>;

if ($text =~ $grammar) {
    my $tree = \%/;
    my $output = {};

    for my $section ($tree->{File}{Section}->@*) {
        my $name = $section->{Header}{Name};
        my $assignments = $section->{Assign};
        $output->{$name} = {
            map { $_->{Key} => $_->{Value} } $assignments->@*
        };
    }

    say JSON->new->utf8->pretty->encode($output);
} else {
    say "Parse failed.";
}

