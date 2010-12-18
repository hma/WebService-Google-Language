#!perl -T

use strict;
use warnings;

use Test::More;

use JSON 2.0 ();
use LWP::UserAgent;

use WebService::Google::Language;

use constant REFERER => 'http://example.com/';

my %accessors = (
  json    => JSON->new,
  ua      => LWP::UserAgent->new,
  referer => REFERER,
);

plan tests => 9 * keys %accessors;

my $service = WebService::Google::Language->new( referer => REFERER );

for my $accessor (sort keys %accessors) {
  can_ok $service, $accessor;

  my $error = qr/'$accessor' requires/;
  eval { $service->$accessor(undef) };
  like   $@, $error, "$accessor (setter) can't undef";

  my $thing = $accessors{$accessor};
  my ($correct, $corrupt);

  if (my $class = ref $thing) {
    $correct = $thing;
    $corrupt = 'foo';

    # check if constructor has auto-generated the object
    isa_ok $service->$accessor, $class;
  }
  else {
    $correct = 'http://search.cpan.org/dist/WebService-Google-Language/';
    $corrupt = ' ';

    is   $service->$accessor, $thing, "$accessor (getter) returned value from construction";
  }

  eval { $service->$accessor($corrupt) };
  like   $@, $error, "$accessor (setter) failed as expected due to invalid parameter";

  my $value = $service->$accessor($correct);
  ok     defined $value,   "$accessor (setter) returned something";
  is     $value, $service, "$accessor can be chained";

  my $gotten = $service->$accessor;
  ok     defined $gotten, "$accessor (getter) returned something";
  is     $gotten, $correct, "$accessor returned given value";

  $gotten = WebService::Google::Language->new(
    $accessor ne 'referer' ? REFERER : (),
    $accessor => $correct
  )->$accessor;
  is     $gotten, $correct, "$accessor as parameter to constructor";
}
