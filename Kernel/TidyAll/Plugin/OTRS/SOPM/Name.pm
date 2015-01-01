# --
# TidyAll/Plugin/OTRS/SOPM/Name.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

package TidyAll::Plugin::OTRS::SOPM::Name;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    my $Code = $Self->_GetFileContents($Filename);

    my ($NameOfTag) = $Code =~ m/<Name>([^<>]+)<\/Name>/;
    my $NameOfFile = substr( basename($Filename), 0, -5 );    # cut off .sopm

    if ( $NameOfTag ne $NameOfFile ) {
        die __PACKAGE__ . "\n" . <<EOF;
The module name $NameOfTag is not equal to the name of the .sopm file ($NameOfFile).
EOF
    }
}

1;
