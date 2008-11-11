package WebService::Google::Language;

use strict;
use warnings;

our $VERSION = '0.05';

use Carp;
use JSON 2.0 ();
use LWP::UserAgent;
use URI::Escape;

use constant GOOGLE_DETECT_URL    => 'http://ajax.googleapis.com/ajax/services/language/detect?v=1.0';
use constant GOOGLE_TRANSLATE_URL => 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0';
use constant MAX_LENGTH           => 500;



#
#  constructor
#

sub new {
  my $class = shift;
  unshift @_, 'referer' if @_ % 2;
  my %conf = @_;

  my $referer = delete $conf{'referer'};
  croak "Constructor requires a non-empty parameter 'referer'"
    unless defined $referer and $referer =~ /\S/;

  my $self = { 'referer' => $referer };
  for (qw(src dest key)) {
    if (defined(my $value = delete $conf{$_})) {
      $self->{$_} = $value;
    }
  }
  bless $self, $class;

  for (qw(json ua)) {
    if (defined(my $value = delete $conf{$_})) {
      $self->$_($value);
    }
  }
  unless ($self->json) {
    $self->json(JSON->new);
  }
  unless ($self->ua) {
    $conf{'agent'} = $class . ' ' . $VERSION unless defined $conf{'agent'};
    # respect proxy environment variables (reported by IZUT)
    $conf{'env_proxy'} = 1 unless exists $conf{'env_proxy'};
    $self->ua(LWP::UserAgent->new(%conf));
  }

  return $self;
}



#
#  public methods
#

sub translate {
  my $self = shift;
  unshift @_, 'text' if @_ % 2;
  my %args = @_;
  my $src  = $args{'src'}  || $self->{'src'}  || '';
  my $dest = $args{'dest'} || $self->{'dest'} || 'en';
  return $self->_request($args{'text'}, $src . '%7C' . $dest);
}

sub detect {
  my $self = shift;
  unshift @_, 'text' if @_ % 2;
  my %args = @_;
  return $self->_request($args{'text'});
}

*detect_language = \&detect;

sub ping {
  my $self = shift;
  return $self->ua
    ->get(GOOGLE_TRANSLATE_URL, 'referer' => $self->{'referer'})
    ->is_success;
}



#
#  accessors
#

sub json {
  my $self = shift;
  if (@_) {
    my $json = shift;
    croak "Accessor requires an object based on 'JSON'"
      unless ref $json and $json->isa('JSON');
    $self->{'json'} = $json;
    return $self;
  }
  $self->{'json'};
}

sub ua {
  my $self = shift;
  if (@_) {
    my $ua = shift;
    croak "Accessor requires an object based on 'LWP::UserAgent'"
      unless ref $ua and $ua->isa('LWP::UserAgent');
    $self->{'ua'} = $ua;
    return $self;
  }
  $self->{'ua'};
}



#
#  private methods and functions
#

sub _request {
  my ($self, $text, $langpair) = @_;
  if (defined $text and $text =~ /\S/) {
    _utf8_encode($text);
    if (length $text > MAX_LENGTH) {
      croak 'Google does not allow submission of text exceeding ' . MAX_LENGTH . ' characters in length';
    }
  }
  else {
    return;
  }
  my $url =
    (defined $langpair ? GOOGLE_TRANSLATE_URL . '&langpair=' . $langpair : GOOGLE_DETECT_URL)
    . (defined $self->{'key'} ? '&key=' . uri_escape($self->{'key'}) : '')
    . '&q=' . uri_escape($text);

  my $response = $self->ua->get($url, 'referer' => $self->{'referer'});

  if ($response->is_success) {
    my $result = eval { $self->json->decode($response->content) };
    if ($@) {
      croak "Couldn't parse response from \"$url\": $@";
    }
    else {
      return bless $result, 'WebService::Google::Language::Result';
    }
  }
  else {
    croak "An HTTP error occured while getting \"$url\": " . $response->status_line;
  }
}

sub _utf8_encode {
  if ($] >= 5.006 and $] < 5.007) {

    # on Perl 5.6 the JSON 2 module (JSON::PP56) provides the missing
    # utf8::encode function, but it seems to be broken
    # my own UTF8 encoder ist tested on ActivePerl 5.6.1.638

    if (length $_[0] == do { use bytes; length $_[0] }) {
      $_[0] = pack 'U*', unpack 'C*', $_[0];
    }
  }
  else {
    utf8::encode($_[0]);
  }
}



#
#  convenience accessor methods to result hash
#

package WebService::Google::Language::Result;

sub error {
  $_[0]->{'responseStatus'} != 200
    ? { 'code'    => $_[0]->{'responseStatus'},
        'message' => $_[0]->{'responseDetails'},
      }
    : undef
}

sub code { $_[0]->{'responseStatus'} }

sub message { $_[0]->{'responseDetails'} }

sub translation {
  defined $_[0]->{'responseData'}
    ? $_[0]->{'responseData'}{'translatedText'}
    : undef
}

sub language {
  defined $_[0]->{'responseData'}
    ? $_[0]->{'responseData'}{'language'} ||
      $_[0]->{'responseData'}{'detectedSourceLanguage'}
    : undef
}

sub is_reliable {
  defined $_[0]->{'responseData'}
    ? $_[0]->{'responseData'}{'isReliable'}
    : undef
}

sub confidence {
  defined $_[0]->{'responseData'}
    ? $_[0]->{'responseData'}{'confidence'}
    : undef
}



1;

__END__

=head1 NAME

WebService::Google::Language - Perl interface to the Google AJAX Language API

=head1 SYNOPSIS

  use WebService::Google::Language;

  $service = WebService::Google::Language->new(
    'referer' => 'http://example.com/',
    'src'     => '',
    'dest'    => 'en',
  );

  $result = $service->translate('Hallo Welt');
  if ($result->error) {
    printf "Error code: %s\n", $result->code;
    printf "Message:    %s\n", $result->message;
  }
  else {
    printf "Detected language: %s\n", $result->language;
    printf "Translation:       %s\n", $result->translation;
  }

  $result = $service->detect('Bonjour tout le monde');
  printf "Detected language: %s\n", $result->language;
  printf "Is reliable:       %s\n", $result->is_reliable ? 'yes' : 'no';
  printf "Confidence:        %s\n", $result->confidence;

=head1 DESCRIPTION

WebService::Google::Language is an object-oriented interface to the
Google AJAX Language API (L<http://code.google.com/apis/ajaxlanguage/>).

The AJAX Language API is a web service to translate and detect the language
of blocks of text.

=head1 CONSTRUCTOR

=over 4

=item $service = WebService::Google::Language->new(%options);

Creates a new C<WebService::Google::Language> object and returns it.

Key/value pair arguments set up the initial state:

  Key       Usage         Expected value
  ---------------------------------------------------------
  referer   mandatory     HTTP referer
  src       optional      default source language
  dest      optional      default destination language
  key       recommended   application's key
  ua        optional      an LWP::UserAgent object for reuse
  json      optional      a JSON object for reuse

Since Google demands a "valid and accurate http referer header" in
requests to their service, a non-empty referer string must be passed
to the constructor. Otherwise the constructor will fail.

Unless the key 'ua' contains an instance of C<LWP::UserAgent>, any additional
entries in the C<%options> hash will be passed unmodified to the constructor
of C<LWP::UserAgent>, which is used for performing the requests.

E.g. you can set your own user agent identification and specify a timeout
this way:

  $service = WebService::Google::Language->new(
    'referer' => 'http://example.com/',
    'agent'   => 'My Application 2.0',
    'timeout' => 5,
  );

Or reuse existing instances of C<LWP::UserAgent> and C<JSON> respectively:

  $service = WebService::Google::Language->new(
    'referer' => 'http://example.com/',
    'ua'      => $my_ua_obj,
    'json'    => $my_json_obj,
  );

=item $service = WebService::Google::Language->new($referer);

=item $service = WebService::Google::Language->new($referer, %options);

Since the referer is the only mandatory parameter, the constructor
can alternatively be called with an uneven parameter list. The first
element will then be taken as the referer, e.g.:

  $service = WebService::Google::Language->new('my-valid-referer');

=back

=head1 METHODS

=over 4

=item $result = $service->translate($text, %args);

=item $result = $service->translate(%args);

The C<translate> method will request the translation of a given text.

Either place the C<$text> as the first parameter to this method or store
it into the arguments hash using the key 'text'.

The source and the destination language can be specified as values of
the keys 'src' and 'dest'. If these parameters are missing, the default
values specified on construction of the object will be used.

If the object has been constructed without default values, the translate
request will default to an empty string for the source language - i.e.
Google will attempt to identify the language of the given text automatically.
The destination language will be set to English (en).

Examples:

  # initialize without custom language defaults
  $service = WebService::Google::Language->new('http://example.com/');

  # auto-detect source language and translate to English
  # (internal defaults)
  $result = $service->translate('Hallo Welt');

  # auto-detect source language and translate to French (fr)
  $result = $service->translate('Hallo Welt', 'dest' => 'fr');

  # set source to English and destination to German (de)
  %args = (
    'text' => 'Hello world',
    'src'  => 'en',
    'dest' => 'de',
  );
  $result = $service->translate(%args);

See Google's documentation for supported languages, language codes
and valid language translation pairs.

=item $result = $service->detect($text);

=item $result = $service->detect('text' => $text);

The C<detect> method will request the detection of the language of
a given text. C<$text> is the single parameter and can be passed directly
or as key 'text' of a hash.

=item $result = $service->detect_language($text);

If C<detect> as a method name is just not descriptive enough, there is
an alias C<detect_language> available.

Examples:

  # detect language
  $result = $service->detect('Hallo Welt');
  # using the more verbose alias
  $result = $service->detect_language('Hallo Welt');

=item $boolean = $service->ping;

Checks if internet access to Google's service is available.

=item $json = $service->json;

Returns the C<JSON> object used by this instance.

=item $service = $service->json($json);

Sets the C<JSON> object to be used by this instance.
Setters return their instance and can be chained.

=item $ua = $service->ua;

=item $service = $service->ua($ua);

Returns/sets the C<LWP::UserAgent> object.

=back

=head1 RESULT ACCESSOR METHODS

Google returns the result encoded as a JSON object which will be
automatically turned into a Perl hash with identically named keys.
See the description of the JSON response at Google's page for the meaning
of the JavaScript properties, which is identical to the Perl hash keys.

To provide some convenience accessor methods to the result, the hash
will be blessed into the package C<WebService::Google::Language::Result>.
The method names are derived from Google's JavaScript class reference
of the AJAX Language API.

The accessors marked as 'no' in the following table will always return
C<undef> for a result from C<translate> or C<detect> respectively.

  Accessor   translate  detect  description
  ---------------------------------------------------------------------
  error         yes      yes    a hash with code and message on error
  code          yes      yes    HTTP-style status code
  message       yes      yes    human readable error message
  translation   yes      no     translated text
  language      yes      yes    detected source language
  is_reliable   no       yes    reliability of detected language
  confidence    no       yes    confidence level, ranging from 0 to 1.0

The L</"SYNOPSIS"> of this module includes a complete example of using the
accessor methods.

=head1 LIMITATIONS

Google does not allow submission of text exceeding 500 characters in length
to their service (see Terms of Use). This module will check the length of
text passed to its methods and will fail if text is too long (without sending
a request to Google).

=head1 SEE ALSO

=over 4

=item * Google AJAX Language API

L<http://code.google.com/apis/ajaxlanguage/>

=item * Terms of Use

L<http://code.google.com/apis/ajaxlanguage/terms.html>

=item * Supported languages

L<http://code.google.com/apis/ajaxlanguage/documentation/#SupportedLanguages>

=item * Class reference

L<http://code.google.com/apis/ajaxlanguage/documentation/reference.html>

=item * L<LWP::UserAgent>

=back

=head1 AUTHOR

Henning Manske (hma@cpan.org)

=head1 ACKNOWLEDGEMENTS

Thanks to Igor Sutton (IZUT) for submitting a patch to enable the use of
proxy environment variables within C<LWP::UserAgent>.

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Henning Manske, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
