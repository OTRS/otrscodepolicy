# --
# TidyAll/Plugin/OTRS/SOPM/RequiredElements.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::RequiredElements;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $OK              = 1;
    my $Name            = 0;
    my $Version         = 0;
    my $Text            = '';
    my $Counter         = 0;
    my $Framework       = 0;
    my $Vendor          = 0;
    my $URL             = 0;
    my $License         = 0;
    my $BuildDate       = 0;
    my $BuildHost       = 0;
    my $DescriptionDE   = 0;
    my $DescriptionEN   = 0;
    my $Table           = 0;
    my $DatabaseUpgrade = 0;
    my $NameLength      = 0;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ /<Name>[^<>]+<\/Name>/ ) {
            $Name = 1;
        }
        elsif ( $Line =~ /<Description Lang="en">[^<>]+<\/Description>/ ) {
            $DescriptionEN = 1;
        }
        elsif ( $Line =~ /<Description Lang="de">[^<>]+<\/Description>/ ) {
            $DescriptionDE = 1;
        }
        elsif ( $Line =~ /<License>([^<>]+)<\/License>/ ) {
            if (
                $1 !~ m{GNU \s GENERAL \s PUBLIC \s LICENSE \s Version \s 2, \s June \s 1991}smx
                && $1
                !~ m{GNU \s AFFERO \s GENERAL \s PUBLIC \s LICENSE \s Version \s 3, \s November \s 2007}smx
                )
            {
                print "WARNING: -------------------------------------------------\n";
                print "WARNING:\n";
                print "WARNING: _OPMRequiredElementsCheck()\n";
                print
                    "WARNING: The License will be set by the opm-builder, you only have to insert 'GNU GENERAL PUBLIC LICENSE Version 2, June 1991'\n";
                print "WARNING:\n";
                print "WARNING: -------------------------------------------------\n";
            }
            $License = 1;
        }
        elsif ( $Line =~ /<URL>([^<>]+)<\/URL>/ ) {
            if ( $1 !~ /http:\/\/otrs\.(org|com)\// ) {
                print "WARNING: -------------------------------------------------\n";
                print "WARNING:\n";
                print "WARNING: _OPMRequiredElementsCheck()\n";
                print
                    "WARNING: The URL will be set by the opm-builder, you only have to insert 'http://otrs.org/' or 'http://otrs.com/'\n";
                print "WARNING:\n";
                print "WARNING: -------------------------------------------------\n";
            }
            $URL = 1;
        }
        elsif ( $Line =~ /<BuildHost>[^<>]*<\/BuildHost>/ ) {
            $BuildHost = 1;
        }
        elsif ( $Line =~ /<BuildDate>[^<>]*<\/BuildDate>/ ) {
            $BuildDate = 1;
        }
        elsif ( $Line =~ /<Vendor>([^<>]+)<\/Vendor>/ ) {
            if ( $1 !~ /OTRS (AG|Inc\.|BV)/ ) {
                $Text .= "WARNING: The vendor should be the 'OTRS AG' or 'OTRS Inc.'\n";
            }
            $Vendor = 1;
        }
        elsif ( $Line =~ /<Framework>([^<>]+)<\/Framework>/ ) {
            $Framework = 1;
        }
        elsif ( $Line =~ /<Version>([^<>]+)<\/Version>/ ) {
            if ( $1 !~ /0\.0\.0/ ) {
                print "WARNING: -------------------------------------------------\n";
                print "WARNING:\n";
                print "WARNING: _OPMRequiredElementsCheck()\n";
                print
                    "WARNING: You don't use <Version>0.0.0</Version>. Do you not want to use the OPMS-module to build the package?\n";
                print "WARNING: You use $1\n";
                print "WARNING:\n";
                print "WARNING: -------------------------------------------------\n";
            }

            $Version = 1;
        }
        elsif ( $Line =~ /<File([^<>]+)>([^<>]*)<\/File>/ ) {
            my $Attributes = $1;
            my $Content    = $2;
            if ( $Content ne '' ) {
                $Text .= "ERROR: Don't insert something between <File><\/File>!\n";
                $OK = 0;
            }
            if ( $Attributes =~ /(Type|Encode)=/ ) {
                $Text .= "ERROR: Don't use the attribute 'Type' or 'Encode' in <File>Tags!\n";
                $OK = 0;
            }
            if ( $Attributes =~ /Location=.+?\.sopm/ ) {
                $Text .= "ERROR: It is senseless to include .sopm-files in a opm! -> $Line";
                $OK = 0;
            }
            if ( $Attributes =~ /Location=.+?\.sql/ ) {
                print "WARNING: -------------------------------------------------\n";
                print "WARNING:\n";
                print "WARNING: _OPMRequiredElementsCheck()\n";
                print "WARNING: In most of the cases it is useless to include .sql-files because\n";
                print "WARNING: the use of the <DatabaseInstall>-Element makes more sense!\n";
                print "WARNING:\n";
                print "WARNING: -------------------------------------------------\n";
            }
        }
        elsif ( $Line =~ /(<Table .+?>|<\/Table>)/ ) {
            $Table = 1;
        }
        elsif ( $Line =~ /<DatabaseUpgrade>/ ) {
            $DatabaseUpgrade = 1;
        }
        elsif ( $Line =~ /<\/DatabaseUpgrade>/ ) {
            $DatabaseUpgrade = 0;
        }
        elsif ( $Line =~ /<Table.+?>/ ) {
            if ( $DatabaseUpgrade && $Line =~ /<Table/ && $Line !~ /Version=/ ) {
                print "ERROR: -------------------------------------------------\n";
                print "ERROR:\n";
                print "ERROR: _OPMRequiredElementsCheck()\n";
                print "ERROR: If you use <Table... in a <DatabaseUpgrade> context you need\n";
                print "ERROR: to have a Version attribute with the beginning version where\n";
                print
                    "ERROR: this change is needed (e. g. <TableAlter Name=\"some_table\" Version=\"1.0.6\">)!\n";
                print "ERROR:\n";
                print "ERROR: -------------------------------------------------\n";
                $OK = 0;
            }
        }

        if ( $Line =~ /<(Column.*|TableCreate.*) Name="(.+?)"/ ) {
            $Name = $2;
            if ( length $Name > 30 ) {
                $NameLength .= "ERROR: Line $Counter: $Name\n";
            }
            elsif ( length $Name > 24 ) {
                print "WARNING: -------------------------------------------------\n";
                print "WARNING:\n";
                print "WARNING: _OPMRequiredElementsCheck()\n";
                print "WARNING: Please use Column and Tablenames with less than 24 letters!\n";
                print "WARNING: Line $Counter: $Name\n";
                print "WARNING:\n";
                print "WARNING: -------------------------------------------------\n";
            }
        }
    }

    if ($Table) {
        $Text
            .= "ERROR: The Element <Table> is not allowed in sopm-files. Perhaps you mean <TableCreate>!\n";
        $OK = 0;
    }
    if ($BuildDate) {
        $Text .= "ERROR: <BuildDate> no longer used in .sopms!\n";
        $OK = 0;
    }
    if ($BuildHost) {
        $Text .= "ERROR: <BuildHost> no longer used in .sopms!\n";
        $OK = 0;
    }

    #if (!$DescriptionDE) {
    #    $Text .= "ERROR: You have forgot to use the element <Description Lang=\"de\">!\n";
    #    $OK = 0;
    #}
    if ( !$DescriptionEN ) {
        $Text .= "ERROR: You have forgot to use the element <Description Lang=\"en\">!\n";
        $OK = 0;
    }
    if ( !$Name ) {
        $Text .= "ERROR: You have forgot to use the element <Name>!\n";
        $OK = 0;
    }
    if ( !$Version ) {
        $Text .= "ERROR: You have forgot to use the element <Version>!\n";
        $OK = 0;
    }
    if ( !$Framework ) {
        $Text .= "ERROR: You have forgot to use the element <Framework>!\n";
        $OK = 0;
    }
    if ( !$Vendor ) {
        $Text .= "ERROR: You have forgot to use the element <Vendor>!\n";
        $OK = 0;
    }
    if ( !$URL ) {
        $Text .= "ERROR: You have forgot to use the element <URL>!\n";
        $OK = 0;
    }
    if ( !$License ) {
        $Text .= "ERROR: You have forgot to use the element <License>!\n";
        $OK = 0;
    }
    if ($NameLength) {
        $Text .= "ERROR: Please use Column and Tablenames with less than 24 letters!\n";
        $Text .= $NameLength;
        $OK = 0;
    }
    if ( !$OK ) {
        die __PACKAGE__ . "\n" . $Text;
    }

    return;
}

1;
