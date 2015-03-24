# --
# TidyAll/Plugin/OTRS/JavaScript/ESLint.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::ESLint;

use strict;
use warnings;

use Capture::Tiny qw(capture_merged);
use base qw(TidyAll::Plugin::OTRS::Base);

our $ESLintPath;
our $ESLintConfigPath;

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    if (!$ESLintPath) {
        $ESLintPath = `which eslint`;
        chomp $ESLintPath;
        if (!$ESLintPath) {
            print STDERR "Could not find 'eslint' script, skipping ESLint tests.\n";
            print STDERR "Install nodejs and run 'npm -g i eslint' to install eslint.\n";
            return;
        }

        $ESLintConfigPath = __FILE__;
        $ESLintConfigPath =~ s{ESLint\.pm}{eslintrc};

        # force minimum version 0.17.1
        my $ESLintVersion = `$ESLintPath -v`;
        chomp $ESLintVersion;
        my ($Major, $Minor, $Patch) = $ESLintVersion =~ m{v(\d+)[.](\d+)[.](\d+)};
        my $Compare = sprintf("%03d%03d%03d", $Major, $Minor, $Patch);
        if (!length($Major) || $Compare < 17_001) {
            undef $ESLintPath;
            die "Your eslint version ($ESLintVersion) is outdated. Please update with 'npm -g update eslint'.\n";
        }
    }

    my $Command = sprintf( "%s -c %s %s", $ESLintPath, $ESLintConfigPath, $Filename );
    my ( $Output, @Result ) = capture_merged { system($Command) };

    if ( @Result && $Result[0] ) {
        die __PACKAGE__ . "\n$Output\n";    # non-zero exit code
    }
}

1;
