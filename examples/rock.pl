#!/usr/bin/env perl

package main;
use strict;
use 5.010;

use lib '../lib';

# Specify the rocks home dir.
# Which can also be set with PERLROCKS_HOME env var.
use perlrocks qw(my-own-rocks);

## Foo.pm is stored under my-own-rocks/ dir.
## Try different version of Foo by uncommenting one of these lines.
## Foo-3.0 or Foo-1.5 pm files do not exists, it'll just die in those cases.
## Versioned `use` means exact match, version-less `use` means the highest version.
# use Foo;
use Foo-1.0;
# use Foo-1.5;
# use Foo-2.0;
# use Foo-3.0;

# Not quite working yet.
# use Foo:<2.0>;

## Other regular 'uses' still search in site_lib
use List::Util qw(first);
use Data::Dumper;

say "Using Foo-" . Foo->version;

say "---";
# Exam the %INC value to see which Foo.pm is `required`.
say Data::Dumper->Dump([\%INC], ['*INC']);
