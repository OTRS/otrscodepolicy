# --
# TidyAll/Plugin/OTRS/SOPM/FileList.pm - code quality plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::FileList;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my ( $ErrorMessageMissingFiles, $ErrorMessageUnpackagedFiles );

    my @SOPMFileList;

    # Only validate files in subdirectories that are active for checking by
    #   default or actually appear on the list of packaged files.
    my %ValidateUnpackagedFilesInDirectories = (
        bin     => 1,
        Custom  => 1,
        Kernel  => 1,
        var     => 1,
        scripts => 1,
    );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        if ( $Line =~ m/<File.*Location="([^"]+)"/ ) {
            my $File = $1;
            push @SOPMFileList, $File;

            my ($ToplevelDirectory) = $File =~ m{^([^/]+)/};
            if ($ToplevelDirectory) {
                $ValidateUnpackagedFilesInDirectories{$ToplevelDirectory} = 1;
            }
        }
    }

    FILE:
    for my $File (@SOPMFileList) {
        if ( !grep { $_ eq $File } @TidyAll::OTRS::FileList ) {
            $ErrorMessageMissingFiles .= "$File\n";
        }
    }

    FILE:
    for my $File (@TidyAll::OTRS::FileList) {

        my ($ToplevelDirectory) = $File =~ m{^([^/]+)/};
        next FILE if ( !$ToplevelDirectory );
        next FILE if !$ValidateUnpackagedFilesInDirectories{$ToplevelDirectory};

        # skip documentation soruce files
        next FILE if $File =~ m{\A doc / [^/]+ / [^\.]+ \. xml \z}msx;

        if ( !grep { $_ eq $File } @SOPMFileList ) {
            $ErrorMessageUnpackagedFiles .= "$File\n";
        }
    }

    my $ErrorMessage;

    if ($ErrorMessageMissingFiles) {
        $ErrorMessage .= <<EOF;
The following files were listed in the SOPM but not found in the directory:
$ErrorMessageMissingFiles
EOF
    }

    if ($ErrorMessageUnpackagedFiles) {
        $ErrorMessage .= <<EOF;
The following files were found in the directory but not listed in the SOPM:
$ErrorMessageUnpackagedFiles
EOF
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
