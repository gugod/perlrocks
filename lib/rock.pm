package rock;
use strict;
use warnings;

use YAML;
use File::Find ();
use File::Spec ();
use B::Hooks::Parser;

# The one, and only, rock.
my $rock = bless {}, __PACKAGE__;

sub rock_root() {
    my @x = File::Spec->splitpath(__FILE__);
    pop @x;
    return File::Spec->catpath(@x, 'rocks');
}

sub parse_use_line($) {
    my ($code) = @_;
    my ($name, $version, $auth);

    # XXX: auth part is not implemented yet.
    if ($code =~ /^use\s+(\S+?)-([0-9._]+).*;$/) {
        $name = $1;
        $version = $2;
    }
    elsif ($code =~ /^use\s(\S+)\s*;$/) {
        $name = $1;
    }

    return ($name, $version, $auth);
}

sub search {
    my ($self, $file, $name, $version, $auth) = @_;

    my @candidates;
    File::Find::find sub {
        return unless $_ eq $file;
        return unless (!$version || $version && $File::Find::name =~ /${name}-${version}\/lib/);

        push @candidates, $File::Find::name;
    }, rock_root;

    if ($version) {
        my ($version_matched) = grep { $_ =~ /${name}-${version}/ } @candidates;
        if ($version_matched) {
            return $version_matched;
        }

        die "ERROR: ${name}-${version} not found in the rocks\n";
    }
    else {
        ## A version-less `use` statement.
        ## Pick the highest versioned from candidates.

        @candidates = map {
            $_->[0]
        } sort {
            $b->[1] <=> $a->[1];
        } map {
            my $v = 0;
            if (/$name-([0-9\.]+)\/lib\/$name/) {
                $v = $1;
            }

            [$_, $v];
        } @candidates;

        return $candidates[0];
    }
}

## It goes here when people says something like `use Foo;` or `use Foo-1.0;`
sub rock::INC {
    my ($self, $module_path) = @_;
    my $code = B::Hooks::Parser::get_linestr();
    my ($name, $version, $auth) = parse_use_line($code);

    my $path = $self->search($module_path, $name, $version, $auth);

    open my $fh, $path or die "Can't open $path for input\n";
    $INC{$module_path} = $path;
    return $fh;
}

## It goes here when people says `use rock;`
sub import {
    unshift @INC, $rock;
}

1;
