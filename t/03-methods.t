#!perl -Tw

use strict;

use Test::More;

use WebService::Google::Language;

my $service = WebService::Google::Language->new('referer' => 'http://search.cpan.org/~hma/');

if ($service->ping) {
  plan 'tests' => 24;
}
else {
  plan 'skip_all' => "Can't reach Google (no internet access?)";
}



#
#  translate
#

  can_ok $service, 'translate';
  ok     !defined $service->translate, 'Call to translate without text parameter returned undef';

SKIP: {
  my $result = eval { $service->translate('Hallo Welt') };

  ok     defined $result, 'translate returned something'
           or skip 'no result (translate failed)', 11;
  isa_ok $result, 'WebService::Google::Language::Result';
  can_ok $result, qw(error translation language)
           or skip 'result misses some methods', 9;
  ok     !$result->error, 'Google could handle translate request';
  is     lc $result->translation, 'hello world', 'Translation is correct';
  is     $result->language, 'de', 'Detected language is correct';

  $result = eval { $service->translate('Hallo Welt', 'src' => 'xx') };

  ok     defined $result, 'translate returned something'
           or skip 'no result (translate failed)', 5;
  isa_ok $result, 'WebService::Google::Language::Result';
  can_ok $result, qw(error code message)
           or skip 'result misses some methods', 3;
  ok     $result->error, 'Google returned an error as expected';
  isnt   $result->code, 200, 'Returned code indicates an error';
  ok     $result->message, 'Error message provided';
}



#
#  detect
#

  can_ok $service, 'detect';
  can_ok $service, 'detect_language';
  ok     !defined $service->detect, 'Call to detect without text parameter returned undef';

SKIP: {
  my $result = eval { $service->detect('Bonjour tout le monde') };

  ok     defined $result, 'detect returned something'
           or skip 'no result (detect failed)', 6;
  isa_ok $result, 'WebService::Google::Language::Result';
  can_ok $result, qw(error language is_reliable confidence)
           or skip 'result misses some methods', 4;
  ok     !$result->error, 'Google could handle detect request';
  is     $result->language, 'fr', 'Detected language is correct';
  ok     $result->is_reliable, 'Detected language is reliable';
  ok     $result->confidence > 0.1, 'There is enough confidence';
}
