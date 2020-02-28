# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::FileList;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

# This module verifies:
#   - that all packaged files of an SOPM are available,
#   - that the SOPM does not try to create new toplevel files or directories in /opt/otrs,
#   - that all files in a valid toplevel directory are also packaged (except for documentation).

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my ( $ErrorMessageMissingFiles, $ErrorMessageUnpackagedFiles, $ErrorMessageForbiddenToplevel );

    # From OTRS 3.3 on, packages cannot create new toplevel directories/files
    #   because of stricter permissions.
    my $AllowOtherToplevelEntries = $Self->IsFrameworkVersionLessThan( 3, 3 ) ? 1 : 0;

    my @SOPMFileList;

    # Only validate files in subdirectories that are active for checking by
    #   default or actually appear on the list of packaged files.
    my %ToplevelDirectories = (
        bin      => 1,
        Custom   => 1,
        doc      => 1,
        Frontend => 1,
        Kernel   => 1,
        scripts  => 1,
        var      => 1,
    );

    # Go trough the files on the SOPM file list
    LINE:
    for my $Line ( split /\n/, $Code ) {
        if ( $Line =~ m/<File.*Location="([^"]+)"/ ) {
            my $File = $1;
            push @SOPMFileList, $File;

            my ($ToplevelDirectory) = $File =~ m{^([^/]+)/};

            # Toplevel file
            if ( !$ToplevelDirectory ) {
                next LINE if $AllowOtherToplevelEntries;

                # Reject new toplevel files for OTRS 3.3+
                $ErrorMessageForbiddenToplevel .= "$File\n";
            }

            # Reject new toplevel directories for OTRS 3.3+
            elsif ( !$AllowOtherToplevelEntries && !$ToplevelDirectories{$ToplevelDirectory} ) {
                $ErrorMessageForbiddenToplevel .= "$File\n";
            }
            else {
                # Accept new toplevel directories for older versions, but then
                #   check that all files in this directory must be on the SOPM file list.
                $ToplevelDirectories{$ToplevelDirectory} = 1;
            }
        }
    }

    # Now check which files on the SOPM list are not available.
    FILE:
    for my $File (@SOPMFileList) {
        if ( !grep { $_ eq $File } @TidyAll::OTRS::FileList ) {
            $ErrorMessageMissingFiles .= "$File\n";
        }
    }

    # For all allowed toplevel directories, every file that is present
    #   must also be packaged.
    FILE:
    for my $File (@TidyAll::OTRS::FileList) {

        my ($ToplevelDirectory) = $File =~ m{^([^/]+)/};
        next FILE if !$ToplevelDirectory;
        next FILE if !$ToplevelDirectories{$ToplevelDirectory};

        # Skip documentation files, these don't have to be on the SOPM list.
        next FILE if $File =~ m{\A doc/ }msx;

        if ( !grep { $_ eq $File } @SOPMFileList ) {
            $ErrorMessageUnpackagedFiles .= "$File\n";
        }
    }

    my $ErrorMessage;

    if ($ErrorMessageForbiddenToplevel) {
        $ErrorMessage .= <<EOF;
The following packaged files try to create new toplevel files or directories in /opt/otrs, which is not possible
due to permission restrictions:
$ErrorMessageForbiddenToplevel
EOF
    }

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
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
