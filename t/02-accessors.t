#!perl -T

use strict;
use warnings;

use Test::More;

use JSON 2.0 ();
use LWP::UserAgent;

use WebService::Google::Language;

my %accessors = (
  json => 'JSON',
  ua   => 'LWP::UserAgent',
);

plan tests => 8 * keys %accessors;

my $service = WebService::Google::Language->new( referer => 'http://search.cpan.org/~hma/' );
my $error   = qr'requires an object based on';
my ($set, $obj, $gotten);

for my $accessor (sort keys %accessors) {

  can_ok $service, $accessor;

  # check if constructor has auto-generated the object
  isa_ok $service->$accessor, my $class = $accessors{$accessor};

  eval { $service->$accessor('foo') };
  like   $@, $error, "$accessor (setter) failed as expected due to invalid parameter";
  eval { $service->$accessor(undef) };
  like   $@, $error, "$accessor (setter) can't undef";

  $set = $class->new;
  $obj = $service->$accessor($set);
  ok     defined $obj,   "$accessor (setter) returned something";
  is     $obj, $service, "$accessor can be chained";

  $gotten = $service->$accessor;
  ok     defined $gotten, "$accessor (getter) returned something";
  is     $gotten, $set,   "$accessor returned initial object";
}
