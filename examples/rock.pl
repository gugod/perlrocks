## perl -I../lib rock.pl

package main;
use strict;
use 5.010;

# Specify the rocks root dir.
use rock qw(my-own-rocks);

## Foo.pm is stored under my-own-rocks/ dir.
## Try different version of Foo by uncommenting one of these lines.
use Foo;
# use Foo-2.0;
# use Foo-3.0;

## Other regular 'uses' still search in site_lib
use List::Util qw(first);
use Data::Dumper;


say "HI";
# say "Using Foo-" . Foo->version;

# Exam the %INC value to see which Foo.pm is `required`.
say Dumper \%INC;
