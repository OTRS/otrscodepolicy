# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::ESLint;

use strict;
use warnings;

use Capture::Tiny qw(capture_merged);
use parent qw(TidyAll::Plugin::OTRS::Base);

our $NodePath;
our $ESLintPath;

sub transform_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    if ( !$ESLintPath ) {

        # On some systems (Ubuntu) nodejs is called /usr/bin/nodejs instead of /usr/bin/node,
        #   which can lead to problems with calling the node scripts directly. Therefore we
        #   determine the nodejs binary and call it directly.
        $NodePath = `which nodejs` || `which node`;
        chomp $NodePath;
        if ( !$NodePath ) {
            print STDERR "Could not find 'nodejs' binary, skipping ESLint tests.\n";
            return;
        }

        $ESLintPath = `which eslint`;
        chomp $ESLintPath;
        if ( !$ESLintPath ) {
            print STDERR "Could not find 'eslint' script, skipping ESLint tests.\n";
            print STDERR "Install nodejs and run 'npm -g i eslint' to install eslint.\n";
            return;
        }

        # Force the minimum version of eslint.
        my $ESLintVersion = `$NodePath $ESLintPath -v`;
        chomp $ESLintVersion;
        my ( $Major, $Minor, $Patch ) = $ESLintVersion =~ m{v(\d+)[.](\d+)[.](\d+)};
        my $Compare = sprintf( "%03d%03d%03d", $Major, $Minor, $Patch );
        if ( !length($Major) || $Compare < 3_000_001 ) {
            undef $ESLintPath;
            die "Your eslint version ($ESLintVersion) is outdated. Please update with 'npm -g update eslint'.\n";
        }
    }

    my $ESLintConfigPath = __FILE__;
    $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/legacy.eslintrc.js};
    if ( $Filename =~ m{Frontend/} ) {
        $ESLintConfigPath = __FILE__;
        $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/frontend.eslintrc.js};
    }
    elsif ( $Filename =~ m{scripts/webpack} ) {
        $ESLintConfigPath = __FILE__;
        $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/webpack.eslintrc.js};
    }

    my $ESLintRulesPath = __FILE__;
    $ESLintRulesPath =~ s{ESLint\.pm}{ESLint/Rules};

    my $Command = sprintf(
        "%s %s -c %s --rulesdir %s --fix %s",
        $NodePath, $ESLintPath, $ESLintConfigPath, $ESLintRulesPath, $Filename
    );

    my ( $Output, @Result ) = capture_merged { system($Command) };

    if ( @Result && $Result[0] ) {
        die __PACKAGE__ . "\n$Output\n";    # non-zero exit code
    }
}

1;
