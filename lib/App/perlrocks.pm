package App::perlrocks;
use strict;
use warnings;
use parent qw(CLI::Framework);

sub command_map {
    search => 'App::perlrocks::Search';
}

sub usage_text {
    <<EOUSAGE

Usage:

    # Install the latest version Mouse
    perlrocks install Mouse

    # Install the specified version of Mouse
    perlrocks install Moose-0.44

    perlrocks search Moose
    #=> Moose (1.13, 1.14)

    perlrocks install Moose
    1. Moose 1.13
    2. Moose 1.14

    perlrocks install Moose-1.14


EOUSAGE
}

1;
