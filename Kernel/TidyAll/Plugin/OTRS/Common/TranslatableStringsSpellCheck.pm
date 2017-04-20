# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::TranslatableStringsSpellCheck;
use strict;
use warnings;

# Implementation is based on https://metacpan.org/source/DROLSKY/Code-TidyAll-0.56/lib/Code/TidyAll/Plugin/PodSpell.pm

use Capture::Tiny qw();
use IPC::Run3;

use parent 'TidyAll::Plugin::OTRS::Base';

our $HunspellPath;
our $HunspellDictionaryPath;
our $HunspellWhitelistPath;

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    if ( !$HunspellPath ) {
        $HunspellPath = `which hunspell`;
        chomp $HunspellPath;
        if ( !$HunspellPath ) {
            print STDERR __PACKAGE__ . "\nCould not find 'hunspell', skipping spell checker tests.\n";
            return;
        }

        $HunspellDictionaryPath = __FILE__;
        $HunspellDictionaryPath =~ s{TranslatableStringsSpellCheck\.pm$}{../StaticFiles/Hunspell/Dictionaries};

        $HunspellWhitelistPath = __FILE__;
        $HunspellWhitelistPath =~ s{\.pm$}{.Whitelist.txt};
    }

    my $Text = $Self->_ExtractTranslatableStrings($File);

    return if !$Text;

    my ( $Output, $Error );
    my @CMD = (
        $HunspellPath,
        '-d', "${HunspellDictionaryPath}/en_US",
        '-p', $HunspellWhitelistPath, "-a"
    );
    eval { run3( \@CMD, \$Text, \$Output, \$Error ) };

    if ( $@ || $Error ) {
        $Error = $@ || $Error;
        die __PACKAGE__ . "\nError running '" . join( " ", @CMD ) . "': " . $Error;
    }

    my ( @Errors, %Seen );
    LINE:
    for my $Line ( split( "\n", $Output ) ) {
        if ( my ( $Original, $Remaining ) = ( $Line =~ /^[\&\?\#] (\S+)\s+(.*)/ ) ) {

            if ( $Original =~ m{^ _? [A-Z]+ [a-z0-9]+ [A-Za-z0-9]* }smx ) {
                next LINE;
            }

            if ( !$Seen{$Original}++ ) {
                my ($Suggestions) = ( $Remaining =~ /: (.*)/ );
                if ($Suggestions) {
                    push( @Errors, sprintf( "%s (suggestions: %s)", $Original, $Suggestions ) );
                }
                else {
                    push( @Errors, $Original );
                }
            }
        }
    }
    die __PACKAGE__ . sprintf( "\nTranslatable strings contains unrecognized words:\n%s\n", join( "\n", sort @Errors ) )
        if @Errors;
}

sub _ExtractTranslatableStrings {
    my ( $Self, $Filename ) = @_;

    my $Code = $Self->_GetFileContents($Filename);

    my $Result;

    if ( $Filename =~ m{.tt$}ismx ) {
        $Code =~ s{
            Translate\(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            $Result .= "$Word\n";

            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.(pm|pl)}ismx ) {
        $Code =~ s{
            (?:
                ->Translate | Translatable
            )
            \(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            # Ignore strings containing variables
            my $SkipWord;
            $SkipWord = 1 if $Word =~ m{\$}xms;

            if ($Word && !$SkipWord ) {
                $Result .= "$Word\n";
            }
            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.xml$}ismx ) {
        $Code =~ s{
            <Data[^>]+Translatable="1"[^>]*>(.*?)</Data>
        }
        {
            my $Word = $1 // '';
            if ($Word) {
                $Result .= "$Word\n";
            }
            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.js$}ismx ) {
        $Code =~ s{
            (?:
                Core.Language.Translate
            )
            \(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            if ( $Word ) {
                $Result .= "$Word\n";
            }

            '';
        }egx;
    }

    return $Result;
}

1;
