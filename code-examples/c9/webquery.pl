use v5.40;
use Web::Query;

wq('webquery.html')
  ->find('.cd')
  ->each(sub {
      my $i = shift;
      say $_->find('.artist')->text, ' - ', $_->find('.title')->text;
  });
