# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS7::TranslatableStringsPlaceholders;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my $Text = $Self->_ExtractTranslatableStrings($File);
    return if !$Text;

    my $ErrorMessage;

    # Prohibit %d as a placeholder.
    while ( $Text =~ /^ (?<Line> [^\n]* % \bd\b [^\n]* ) $/gismx ) {
        $ErrorMessage .= $+{Line} . "\n";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Translatable strings contain prohibited placeholders (\%d):\n
$ErrorMessage
EOF
    }

    return;
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
            [^>]+Translatable="1"[^>]*>(.*?)</
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
    elsif ( $Filename =~ m{\.html\.tmpl$}ismx ) {
        $Code =~ s{
            \{\{
            \s*
            (["'])(.*?)(?<!\\)\1
            \s*
            \|
            \s*
            Translate
        }
        {
            my $Word = $2 // '';

            # Unescape any \" or \' signs.
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
