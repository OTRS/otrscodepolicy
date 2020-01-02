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

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        $Line =~ s{\[gettimeofday\]}{1}smx;

        # We'll skip all use *; statements exept for core modules because the modules cannot be found at runtime.
        ## nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)
        if (
            $Line =~ m{ \A \s* use \s+ }xms
            && $Line
            !~ m{\A \s* use \s+ (?: vars | constant | strict | warnings | Fcntl | Data::Dumper | threads | Readonly | lib | FindBin | IO::Socket | File::Basename | Moo | Perl::Critic::Utils | List::Util | Cwd | POSIX ) }xms
            )
        {
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
