package App::perlrocks;
use strict;
use warnings;
use parent qw(CLI::Framework);

sub command_map {
    search  => 'App::perlrocks::Search',
    install => 'App::perlrocks::Install',
}

sub usage_text {
    <<EOUSAGE

Usage:

    perlrocks search Moose
    #=> Moose (1.14 1.13)

    # Install the latest version Moose
    perlrocks install Moose

    # Install the specified version of Moose
    perlrocks install -v 1.14 Moose

EOUSAGE
}

1;
