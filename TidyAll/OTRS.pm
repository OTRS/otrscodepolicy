# --
# TidyAll/OTRS.pm - OTRS extensions for Code::TidyAll
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

package TidyAll::OTRS;

use IO::File;
use base qw(Code::TidyAll);

sub new_from_conf_file {
    my ($Class, $ConfigFile, %Param) = @_;

    # possibly call Parent->new(@args) first
    my $Self = $Class->SUPER::new_from_conf_file($ConfigFile, %Param);

    return $Self;
}

sub DetermineFrameworkVersionFromDirectory {
    my ($Self, %Param) = @_;

    print "Checking OTRS framework version... ";

    $Self->{FrameworkVersionMajor} = 0;
    $Self->{FrameworkVersionMinor} = 0;

    # First check if we have an OTRS directory, use RELEASE info then.
    if (-r $Self->{root_dir} . '/RELEASE') {
        my $FileHandle = IO::File->new( $Self->{root_dir} . '/RELEASE', 'r' );
        my @Content = $FileHandle->getlines();

        my ($VersionMajor, $VersionMinor) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $Self->{FrameworkVersionMajor} = $VersionMajor;
        $Self->{FrameworkVersionMinor} = $VersionMinor;
    }
    else {
        # Now check if we have a module directory with an SOPM file in it.
        my @SOPMFiles = glob $Self->{root_dir} . "/*.sopm";
        if (@SOPMFiles) {
            # Use the highest framework version from the first SOPM file.
            my $FileHandle = IO::File->new( $SOPMFiles[0], 'r' );
            my @Content = $FileHandle->getlines();
            for my $Line (@Content) {
                if ($Line =~ m{<Framework>}) {
                    my ($VersionMajor, $VersionMinor) = $Line =~ m{<Framework>(\d+)\.(\d+)\.[^<*]</Framework>}xms;
                    if ( $VersionMajor > $Self->{FrameworkVersionMajor}
                        || ( $VersionMajor == $Self->{FrameworkVersionMajor}
                            && $VersionMinor > $Self->{FrameworkVersionMinor} )
                    ) {
                        $Self->{FrameworkVersionMajor} = $VersionMajor;
                        $Self->{FrameworkVersionMinor} = $VersionMinor;
                    }
                }
            }
        }
    }

    if ($Self->{FrameworkVersionMajor}) {
        print "found OTRS version $Self->{FrameworkVersionMajor}.$Self->{FrameworkVersionMajor}\n";
        return;
    }

    print "could not determine OTRS version!\n";
    return;
}

1;
