#!perl -T

use strict;
use warnings;

use Test::More;

use WebService::Google::Language;

my $result = bless {}, 'WebService::Google::Language::Result';

my @accessors = qw'error code message translation language is_reliable confidence';

plan tests => 2 * @accessors;

for (@accessors) {
  my @ret = $result->$_;
  ok exists $ret[0] && ! defined $ret[0], "Call to '$_' returned undef";
  ok keys %$result == 0, "result not changed by '$_'";
}
