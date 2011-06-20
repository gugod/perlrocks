package App::perlrocks::Install;
use 5.012;
use strict;
use warnings;
use utf8;
use parent 'CLI::Framework::Command';
use App::perlrocks::Helpers;
use File::Temp qw(tempfile tempdir);

require perlrocks;

sub option_spec { (
    [ 'version|v=s' => 'Specify the version of distribution to install.' ]
) }

sub run {
    my ($self, $opts, $dist_name) = @_;

    my $dist_release;
    my $dist_version = $opts->{version};

    if (defined $dist_version) {
        $dist_release = the_release_of_dist($dist_name, $dist_version);
    } else {
        $dist_release = the_latest_release_of_dist($dist_name);
        $dist_version = $dist_release->{version};
    }

    unless($dist_release->{download_url}) {
        die "Failed to find $dist_name $dist_version\n";
    }

    # The $dist_release->{name} should be formatted like Moose-2.100
    my $install_base = File::Spec->catdir(perlrocks->home, $dist_release->{name});

    print "Installing $dist_release->{name} to $install_base\n";
    install_cpan_dist_to_dir($dist_release->{download_url}, $install_base);

    return $dist_release->{name} . " is installed to $install_base\n";
}

sub install_cpan_dist_to_dir {
    my $dist_url = shift;
    my $install_base  = shift;

    require local::lib;# , $install_base;

    local::lib->ensure_dir_structure_for($install_base);
    my %env = local::lib->build_environment_vars_for($install_base, 0);

    my ($fh, $filename) = tempfile(SUFFIX => '.sh');

    print $fh "#!/bin/sh\n";
    for (keys %env) {
        print $fh "export $_=\"$env{$_}\"\n";
    }
    print $fh "cpanm -nq --reinstall $dist_url\n";
    close($fh);
    system("/bin/sh", $filename);
    return $install_base;
}

sub the_latest_release_of_dist {
    my ($dist_name) = @_;
    return metacpan_request("/release/" . $dist_name);
}

sub the_release_of_dist {
    my ($name, $version) = @_;
    return metacpan_request(
        "/release/_search",
        {
            query => {
                field => {
                    "release.name" => "$name-$version"
                }
            }
        },
        sub {
            my $data = shift;
            $data->{hits}{hits}[0]{_source}
        }
    );
}

1;
