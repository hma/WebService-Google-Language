use 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME               => 'WebService::Google::Language',
  AUTHOR             => 'Henning Manske <hma@cpan.org>',
  VERSION_FROM       => 'lib/WebService/Google/Language.pm',
  ABSTRACT_FROM      => 'lib/WebService/Google/Language.pm',
  ($ExtUtils::MakeMaker::VERSION ge 6.3002 ? ( LICENSE => 'perl') : ()),
  PL_FILES           => {},
  PREREQ_PM => {
    'Carp'           => 0,
    'JSON'           => 2.0,
    'LWP::UserAgent' => 0,
    'Test::More'     => 0,
    'URI'            => 0,
  },
  dist               => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
  clean              => { FILES => 'WebService-Google-Language-*' },
);
