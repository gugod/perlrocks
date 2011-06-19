package App::perlrocks::Helpers;
use strict;
use warnings;
use HTTP::Tiny;
use JSON qw(from_json to_json);

use Exporter::Lite;
our @EXPORT = qw(metacpan_request);

sub metacpan_request {
    my ($path, $data, $cb) = @_;
    if (ref($data) eq 'CODE') {
        $cb = $data;
        $data = undef;
    }

    my $response = HTTP::Tiny->new->request(
        "POST",
        "http://api.metacpan.org" . $path,
        {
            content => defined($data) ? to_json($data) : ''
        }
    );

    if ($response->{success}) {
        my $data = from_json($response->{content});
        return $cb ? $cb->($data) : $data;
    }

    die "Request failed: " . to_json($response);
}


1;
