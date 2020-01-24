# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::SyntaxCheck;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

use File::Temp;

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my ( $CleanedSource, $DeletableStatement );

    # Allow important modules that come with the Perl core or are external
    #   dependencies of OTRS and can thus be assumed as being installed.
    my @AllowedExternalModules = qw(
        vars
        constant
        strict
        warnings
        threads
        lib

        Archive::Zip
        Archive::Tar
        Cwd
        Carp
        Data::Dumper
        DateTime
        DBI
        Fcntl
        File::Basename
        FindBin
        IO::Socket
        List::Util
        Moo
        Moose
        Perl::Critic::Utils
        POSIX
        Readonly
        Template
        Time::HiRes
    );

    my $AllowedExternalModulesRegex = '\A \s* use \s+ (?: ' . join( '|', @AllowedExternalModules ) . ' ) ';

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        # We'll skip all use *; statements exept for core modules because the modules cannot be found at runtime.
        if ( $Line =~ m{ \A \s* use \s+ }xms && $Line !~ m{$AllowedExternalModulesRegex}xms ) {
            $DeletableStatement = 1;
        }

        if ($DeletableStatement) {
            $Line = "#$Line";
        }

        if ( $Line =~ m{ ; \s* \z }xms ) {
            $DeletableStatement = 0;
        }

        $CleanedSource .= $Line . "\n";
    }

    #print STDERR $CleanedSource;

    my $TempFile = File::Temp->new();
    print $TempFile $CleanedSource;
    $TempFile->flush();

    # syntax check
    my $ErrorMessage;
    my $FileHandle;
    if ( !open $FileHandle, '-|', "perl -cw " . $TempFile->filename() . " 2>&1" ) {    ## no critic
        die __PACKAGE__ . "\nFILTER: Can't open tempfile: $!\n";
    }

    while ( my $Line = <$FileHandle> ) {
        if ( $Line !~ /(syntax OK|used only once: possible typo)/ ) {
            $ErrorMessage .= $Line;
        }
    }
    close $FileHandle;

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
