use strict;
use warnings;
use ExtUtils::MakeMaker;

my %conf = (
    NAME                => 'WebService::Google::Language',
    AUTHOR              => 'Henning Manske <hma@cpan.org>',
    VERSION_FROM        => 'lib/WebService/Google/Language.pm',
    ABSTRACT_FROM       => 'lib/WebService/Google/Language.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Carp'           => 0,
        'JSON'           => 2.0,
        'LWP::UserAgent' => 0,
        'URI::Escape'    => 0,
        'Test::More'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-Google-Language-*' },
);

$conf{'LICENSE'} = 'perl' if $ExtUtils::MakeMaker::VERSION > '6.30';

WriteMakefile(%conf);
