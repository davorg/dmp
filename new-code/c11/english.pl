use v5.40;
use builtin qw(trim);
use feature 'signatures';
no warnings 'experimental::signatures';

use Regexp::Grammars;

my $grammar = qr{
    <nocontext:>
    \A <Sentence> \Z

    <rule: Sentence>
        <Subject> <Verb> <Object>

    <rule: Subject>
        <NounPhrase>

    <rule: Object>
        <NounPhrase>

    <rule: Verb>
        wrote | likes | ate

    <rule: NounPhrase>
        <Pronoun> | <ProperNoun> | <Article> <Noun>

    <rule: Article>
        a | the | this

    <rule: Pronoun>
        it | he

    <rule: ProperNoun>
        Perl | Dave | Larry

    <rule: Noun>
        book | cat
}x;

while (<DATA>) {
    chomp(my $line = $_);
    print "'$line' is ";
    print 'NOT ' unless $line =~ $grammar;
    say "a valid sentence";
}

__DATA__
Larry wrote Perl
Larry wrote a book
Dave likes Perl
Dave likes the book
Dave wrote this book
the cat ate the book
Dave got very angry
