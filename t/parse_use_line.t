#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

require perlrocks;

# Perl 5 syntax
is_deeply([perlrocks::parse_use_line('use Dog 1.2.1;')], ['Dog', '1.2.1', undef], 'use Dog 1.2.1;');
is_deeply([perlrocks::parse_use_line('use Dog-1.2.1;')], ['Dog', '1.2.1', undef], 'use Dog-1.2.1;');

# Perl 6 syntax (S11)
is_deeply([perlrocks::parse_use_line('use Dog:<1.2.1>;')],              ['Dog', '1.2.1', undef], 'use Dog:<1.2.1>;');
is_deeply([perlrocks::parse_use_line('use Dog:ver<1.2.1>;')],           ['Dog', '1.2.1', undef], 'use Dog:ver<1.2.1>;');
is_deeply([perlrocks::parse_use_line('use Dog:auth(Any):ver<1.2.1>;')], ['Dog', '1.2.1', undef], 'use Dog:auth(Any):ver<1.2.1>;');


done_testing;
