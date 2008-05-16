#!perl -Tw

use Test::More 'tests' => 1;

BEGIN {
  use_ok 'WebService::Google::Language'
    or BAIL_OUT "Module doesn't load";
}
