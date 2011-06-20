package perlrocks;

=head1 NAME

perlrocks - CPAN installation management

=head1 VERSION

0.01

=head1 SYNOPSIS

A command 'rock' is installed:

    > rock search Moose

    # Install multiple vesion of Moose
    > rock install Moose-1.14
    > rock install Moose-1.13

    # Uninstall is possible
    > rock uninstall Moose-1.14


perlrocks does not work transparently, you have to modify your program a little bit.

    # Have to say this in the very beginning of your program.
    use perlrocks;

    # Using the latest version of intsalled Moose
    use Moose;

    # Using a specific version of Moose.
    use Moose-1.13;

=head1 METHODS

=cut

use strict;
use warnings;

our $VERSION = '0.01';

use File::Find ();
use File::Spec;
use File::ShareDir qw(dist_dir);

my $PERLROCKS_WITH_B_HOOKS_PARSER = 0;
BEGIN {
    eval "require B::Hooks::Parser";
    if (!$@) {
        B::Hooks::Parser->import;
        $PERLROCKS_WITH_B_HOOKS_PARSER = 1;
    }
}

# The one, and only, rock.
my $rock = bless {}, __PACKAGE__;

sub home() {
    return $rock->{home} ||= ($ENV{PERLROCKS_HOME} || dist_dir('perlrocks'));
}

sub parse_use_line($) {
    my ($code) = @_;
    my ($name, $version, $auth);

    # Perl6 syntax
    my $ident = '[a-zA-Z0-9]+';
    if ($code =~ /^use\s+( (?:${ident}::)* ${ident} ):(?:auth\(Any\):)?(?:ver)?<(v?[\d+ '.']*\d+)>;$/x) {
        return ($1, $2, undef);
    }

    # Perl 5 syntax
    if ($code =~ /^use\s+(\S+?)(?:-|\s+)([0-9._]+).*;$/) {
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
    }, $self->home;

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

{
    no warnings 'redefine';
    if ($PERLROCKS_WITH_B_HOOKS_PARSER) {
        sub get_current_line {
            B::Hooks::Parser::get_linestr();
        }
    }
    else {
        sub get_current_line {
            my (undef, $file, $lineno) = caller(2);
            open my $fh, "<", $file;
            my $line;
            my $i = 0;
            while ($i < $lineno) {
                $line = <$fh>;
                $i++;
            }
            close($fh);
            return $line;
        }
    }
}

## It goes here when people says something like `use Foo;` or `use Foo-1.0;`
sub perlrocks::INC {
    my ($self, $module_path) = @_;
    my $code = get_current_line();
    return unless $code;

    my ($name, $version, $auth) = parse_use_line($code);

    return unless $name;

    my $path = $self->search($module_path, $name, $version, $auth);

    if ($path) {
        open my $fh, $path or die "Can't open $path for input\n";
        $INC{$module_path} = $path;
        return $fh;
    }
}

## It goes here when people says `use perlrock;`
sub import {
    my ($class, $perlrocks_home) = @_;;
    if ($PERLROCKS_WITH_B_HOOKS_PARSER) {
        $rock->{__parser_hook} = B::Hooks::Parser::setup();
    }

    $rock->{home} = $perlrocks_home;
    unshift @INC, $rock;
}

sub unimport {
    if ($rock->{__parser_hook}) {
        B::Hooks::Parser::teardown($rock->{__parser_hook});
        delete $rock->{__parser_hook};
    }
}

1;

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 COPYRIGHT

Copyright (c) 2011 Kang-min Liu C<< <gugod@gugod.org> >>.

=head1 LICENCE

The MIT License

=head1 CONTRIBUTORS

See L<https://github.com/gugod/perlrocks/contributors>

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
