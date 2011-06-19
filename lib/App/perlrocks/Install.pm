package App::perlrocks::Install;
use 5.012;
use strict;
use warnings;
use utf8;
use parent 'CLI::Framework::Command';
use HTTP::Tiny;
use JSON qw(from_json);

sub option_spec { (
    [ 'version|v' => 'Specify the version of distribution to install.' ]
) }

sub run {
    my ($self, $opts, @args) = @_;
    my ($dist_name) = @args;
    my $dist_release;
    my $dist_version = $opts->{version};
    if (defined $dist_version) {
    } else {
        $dist_release = the_latest_release_of_dist($dist_name);
        $dist_version = $dist_release->{version};
    }
}

sub install_cpan_dist_to_dir {
    my $dist_url = shift;
    my $install_base  = shift;

    require local::lib, $install_base;

    local::lib->ensure_dir_structure_for($install_base);
    my %env = local::lib->build_environment_vars_for($install_base, 0);

    my ($fh, $filename) = tempfile(SUFFIX => '.sh');

    print $fh "#!/bin/sh\n";
    for (keys %env) {
        print $fh "export $_=\"$env{$_}\"\n";
    }
    print $fh "cpanm -nq --reinstall $dist_url\n";
    print "run $filename\n";
    close($fh);
    system("/bin/sh", $filename);
    return $install_base;
}

sub the_latest_release_of_dist {
    my ($dist_name) = @_;

    my $response = HTTP::Tiny->new->request("GET", "http://api.metacpan.org/release/" . $dist_name);

    unless ($response->{success}) {
        die "metacpan request failed.\n";
    }

    return from_json($response->{content});
}

1;
