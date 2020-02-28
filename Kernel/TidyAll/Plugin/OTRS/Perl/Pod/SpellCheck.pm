# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Pod::SpellCheck;
use strict;
use warnings;

# Implementation is based on https://metacpan.org/source/DROLSKY/Code-TidyAll-0.56/lib/Code/TidyAll/Plugin/PodSpell.pm

use Capture::Tiny qw();
use File::Temp();
use Pod::Spell;

use parent 'TidyAll::Plugin::OTRS::Perl';

our $HunspellPath;
our $HunspellDictionaryPath;
our $HunspellWhitelistPath;

sub validate_file {
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
        $HunspellDictionaryPath =~ s{SpellCheck\.pm$}{../../StaticFiles/Hunspell/Dictionaries};

        $HunspellWhitelistPath = __FILE__;
        $HunspellWhitelistPath =~ s{\.pm$}{.Whitelist.txt};
    }

    # # TODO: MOVE TO SEPARATE Perl::CommentsSpellCheck plugin later
    # my $Code = $Self->_GetFileContents($File);
    #
    # my $Comments = $Self->StripPod( Code => $Code );
    # $Comments    =~ s{^ \# \s stripped \s POD}{}smxg;
    # $Comments    =~ s{^ \s* [^#\s] .*? $}{}smxg;  # Remove non-comment lines
    # $Comments    =~ s{\n\n+}{\n}smxg;             # Remove empty blocks
    # $Comments    =~ s{^ \s* [#] \s* }{}smxg;      # Remove comment signs

    my ( $PodText, $Error )
        = Capture::Tiny::capture( sub { Pod::Spell->new()->parse_from_file( $File->stringify() ) } );
    die $Error if $Error;

    my $TempFile = File::Temp->new();
    print $TempFile $PodText;
    $TempFile->close();

    my $CMD    = "$HunspellPath -d ${HunspellDictionaryPath}/en_US -p $HunspellWhitelistPath -a $TempFile";
    my $Output = `$CMD`;

    if ( ${^CHILD_ERROR_NATIVE} ) {
        return $Self->DieWithError("Error running '$CMD': $Output");
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
    if (@Errors) {
        return $Self->DieWithError(
            sprintf( "\nPerl Pod contains unrecognized words:\n%s\n", join( "\n", sort @Errors ) )
        );
    }

    return;
}

1;
