#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

use WebService::Google::Language;

eval { WebService::Google::Language->new };
ok     $@, 'Construction failed as expected due to missing mandatory parameter';

my $service = eval { WebService::Google::Language->new( referer => 'http://search.cpan.org/~hma/' ) };

isa_ok $service, 'WebService::Google::Language'
  or BAIL_OUT q{Can't create a WebService::Google::Language object};
