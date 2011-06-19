package App::perlrocks::Search;
use 5.012;
use strict;
use warnings;
use utf8;
use parent 'CLI::Framework::Command';
use App::perlrocks::Helpers;

sub run {
    my ($self, $opts, @args) = @_;
    my ($name) = @args;

    my $v = search_release_by_name($name);

    my $ret = "";
    for (@$v) {
        $ret .= $_->{distribution} . " (";
        $ret .= join " ", map { $_->{version} } @{$_->{versions}};
        $ret .= ")\n";
    }
    return $ret;
}

sub search_release_by_name {
    my ($dist_name) = @_;

    my $versions = metacpan_request(
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
        },
        sub {
            return [map { $_->{fields} } @{ $_[0]->{hits}{hits} }];
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
