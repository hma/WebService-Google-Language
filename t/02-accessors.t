#!perl -Tw

use strict;

use Test::More 'tests' => 6;

use WebService::Google::Language;

my $service = WebService::Google::Language->new('referer' => 'http://search.cpan.org/~hma/');



#
#  json
#

can_ok $service, 'json';
my $json = $service->json;
ok     defined $json, 'json returned something';
isa_ok $json, 'JSON';



#
#  ua
#

can_ok $service, 'ua';
my $ua = $service->ua;
ok     defined $ua, 'ua returned something';
isa_ok $ua, 'LWP::UserAgent';
