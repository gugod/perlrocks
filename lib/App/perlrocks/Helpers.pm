package App::perlrocks::Helpers;
use strict;
use warnings;
use HTTP::Tiny;
use JSON qw(from_json to_json);

use Exporter::Lite;
our @EXPORT = qw(metacpan_request);

sub metacpan_request {
    my ($path, $data) = @_;
    my $response = HTTP::Tiny->new->request(
        "POST",
        "http://api.metacpan.org" . $path,
        {
            content => to_json($data)
        }
    );

    if ($response->{success}) {
        my @hits = map {
            $_->{fields}
        } @{ from_json($response->{content})->{hits}{hits} };
        return \@hits;
    }
    die "Request failed.";
}


1;
