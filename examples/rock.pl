## perl -I../lib rock.pl

package main;
use strict;
use 5.010;

# Specify the rocks root dir.
use perlrocks qw(my-own-rocks);

## Foo.pm is stored under my-own-rocks/ dir.
## Try different version of Foo by uncommenting one of these lines.
## There is no Foo-3.0 pm file, it'll just die in that case.
## Versioned `use` means exact match, version-less `use` means the highest version.
use Foo;
# use Foo-1.0;
# use Foo-2.0;
# use Foo-3.0;

## Other regular 'uses' still search in site_lib
use List::Util qw(first);
use Data::Dumper;

say "Using Foo-" . Foo->version;

say "---";
# Exam the %INC value to see which Foo.pm is `required`.
say Data::Dumper->Dump([\%INC], ['*INC']);
