#!perl -T

use strict;
use warnings;

use Test::More tests => 16;

use JSON 2.0 ();
use LWP::UserAgent;

use WebService::Google::Language;

my $service = WebService::Google::Language->new( referer => 'http://search.cpan.org/~hma/' );
my ($set, $obj, $gotten);



#
#  json
#

can_ok $service, 'json';

# check if constructor has auto-generated the json object
isa_ok $service->json, 'JSON';

eval { $service->json('foo') };
like   $@, qr/requires an object based on/, 'json (setter) failed as expected due to invalid parameter';
eval { $service->json(undef) };
ok     $@, q{json can't undef};

$set = JSON->new;
$obj = $service->json($set);
ok     defined $obj, 'json (setter) returned something';
is     $obj, $service, 'json can be chained';

$gotten = $service->json;
ok     defined $gotten, 'json (getter) returned something';
is     $gotten, $set, 'json returned initial object';



#
#  ua
#

can_ok $service, 'ua';

# check if constructor has auto-generated the ua object
isa_ok $service->ua, 'LWP::UserAgent';

eval { $service->ua('foo') };
like   $@, qr/requires an object based on/, 'ua (setter) failed as expected due to invalid parameter';
eval { $service->ua(undef) };
ok     $@, q{ua can't undef};

$set = LWP::UserAgent->new;
$obj = $service->ua($set);
ok     defined $obj, 'ua (setter) returned something';
is     $obj, $service, 'ua can be chained';

$gotten = $service->ua;
ok     defined $gotten, 'ua (getter) returned something';
is     $gotten, $set, 'ua returned initial object';
