package App::perlrocks::Search;
use 5.012;
use strict;
use warnings;
use utf8;
use parent 'CLI::Framework::Command';
use HTTP::Tiny;
use JSON qw(from_json to_json);

sub run {
    my ($self, $opts, @args) = @_;
    my ($name) = @args;

    my $v = versions_of_dist($name);

    my $ret = "";
    for (@$v) {
        $ret .= $_->{distribution};
        for (@{$_->{versions}}) {
            $ret .= " $_->{version}";
        }
        $ret .= "\n";
    }
    return $ret;
}

sub http_request {
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

sub versions_of_dist {
    my ($dist_name) = @_;

    my $versions = http_request(
        '/release/_search', {
            query => {
                query_string => {
                    fields => [
                        'distribution^1000',
                        'distribution.analyzed',
                        'name.analyzed',
                    ],
                    query => $dist_name
                }
            },
            size   => 1000, # YYY: Something that's large enought to cover all...
            sort   => [ "_score", { date => 'desc' } ],
            fields => [qw(name distribution date author version status download_url)],
        }
    );

    my @ret = ();
    my $pos = {};
    for(@$versions) {
        my $dist = $_->{distribution};

        unless (defined $pos->{$dist}) {
            push @ret, {
                distribution => $dist,
                versions => []
            };

            $pos->{$dist} = $#ret;
        }
        push @{$ret[$pos->{$dist}]->{versions}}, $_;
    }

    return \@ret;
}

1;
