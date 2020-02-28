# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::ESLint;

use strict;
use warnings;

use Encode;
use parent qw(TidyAll::Plugin::OTRS::Base);

our $NodePath;
our $ESLintPath;

sub transform_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    if ( !$ESLintPath ) {

        # On some systems (Ubuntu) nodejs is called /usr/bin/nodejs instead of /usr/bin/node,
        #   which can lead to problems with calling the node scripts directly. Therefore we
        #   determine the nodejs binary and call it directly.
        $NodePath = `which nodejs 2>/dev/null` || `which node 2>/dev/null`;
        chomp $NodePath;
        if ( !$NodePath ) {
            die "Error: could not find the 'nodejs' binary.\n";
        }

        $ESLintPath = `which eslint 2>/dev/null`;
        chomp $ESLintPath;
        if ( !$ESLintPath ) {
            die "Error: could not find the 'eslint' script.\n";
        }

        # Force the minimum version of eslint.
        my $ESLintVersion = `$NodePath $ESLintPath -v`;
        chomp $ESLintVersion;
        my ( $Major, $Minor, $Patch ) = $ESLintVersion =~ m{v(\d+)[.](\d+)[.](\d+)};
        my $Compare = sprintf( "%03d%03d%03d", $Major, $Minor, $Patch );
        if ( !length($Major) || $Compare < 5_000_001 ) {
            undef $ESLintPath;    # Make sure to re-issue this error for future files.
            die "Error: your eslint version ($ESLintVersion) is outdated.\n";
        }
    }

    my $ESLintConfigPath = __FILE__;
    $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/legacy.eslintrc.js};
    if ( $Filename =~ m{Frontend/} ) {
        my $ESLintConfigFile = 'ESLint/frontend.eslintrc.js';

        # A little more lenient before OTRS 8 (certain rules will be turned off).
        if ( $Self->IsFrameworkVersionLessThan( 8, 0 ) ) {
            $ESLintConfigFile = 'ESLint/frontend.eslintrc.7.js';
        }

        $ESLintConfigPath = __FILE__;
        $ESLintConfigPath =~ s{ESLint\.pm}{$ESLintConfigFile};
    }
    elsif ( $Filename =~ m{scripts/webpack} ) {
        $ESLintConfigPath = __FILE__;
        $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/webpack.eslintrc.js};
    }

    my $ESLintRulesPath = __FILE__;
    $ESLintRulesPath =~ s{ESLint\.pm}{ESLint/Rules};

    my $Command = sprintf(
        "%s %s -c %s --rulesdir %s --fix %s --quiet",
        $NodePath, $ESLintPath, $ESLintConfigPath, $ESLintRulesPath, $Filename
    );

    my $Output = `$Command`;
    if ( ${^CHILD_ERROR_NATIVE} || $Output ) {
        Encode::_utf8_on($Output);
        return $Self->DieWithError("$Output\n");
    }
}

1;
