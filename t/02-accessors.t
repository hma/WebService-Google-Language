#!perl -Tw

use strict;

use Test::More 'tests' => 12;

use JSON 2.0 ();
use LWP::UserAgent;

use WebService::Google::Language;

my $service = WebService::Google::Language->new('referer' => 'http://search.cpan.org/~hma/');



#
#  json
#

can_ok $service, 'json';
my $json = $service->json;
ok     defined $json, 'json (getter) returned something';
isa_ok $json, 'JSON';

eval { $service->json(undef) };
ok     $@, 'json (setter) failed as expected due to invalid parameter';
my $obj = eval { $service->json(JSON->new) };
ok     defined $obj, 'json (setter) returned something';
ok     $obj eq $service, 'json can be chained';



#
#  ua
#

can_ok $service, 'ua';
my $ua = $service->ua;
ok     defined $ua, 'ua (getter) returned something';
isa_ok $ua, 'LWP::UserAgent';

eval { $service->ua(undef) };
ok     $@, 'ua (setter) failed as expected due to invalid parameter';
$obj = eval { $service->ua(LWP::UserAgent->new) };
ok     defined $obj, 'ua (setter) returned something';
ok     $obj eq $service, 'json can be chained';
