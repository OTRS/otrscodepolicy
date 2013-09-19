# --
# TidyAll/Plugin/OTRS/SOPM/FileList.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
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
    return if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    my ( $ErrorMessageMissingFiles, $ErrorMessageUnpackagedFiles );

    my @SOPMFileList;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        if ( $Line =~ m/<File.*Location="([^"]+)".*\/>/ ) {
            push @SOPMFileList, $1;
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
        # Files to ignore. Only list files here which may be present
        #   in the git repositories. Others should be ignored in
        #   TidyAll::OTRS::GetFileListFromDirectory().
        next if substr( $File, 0, 3 ) eq 'doc';
        next if substr( $File, 0, 11 ) eq 'development';
        next if substr( $File, -5 ) eq '.sopm';
        next if $File =~ m{(^|/)[.]};    # ignore hidden files

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
