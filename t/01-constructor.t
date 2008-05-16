#!perl -Tw

use strict;

use Test::More 'tests' => 3;

use WebService::Google::Language;

my $service = eval { WebService::Google::Language->new };

ok     $@, 'Construction failed as expected due to missing mandatory parameter';

$service = eval { WebService::Google::Language->new('referer' => 'http://search.cpan.org/~hma/') };

ok     defined $service, 'Constructor returned something';
isa_ok $service, 'WebService::Google::Language'
         or BAIL_OUT "Can't create a WebService::Google::Language object";
