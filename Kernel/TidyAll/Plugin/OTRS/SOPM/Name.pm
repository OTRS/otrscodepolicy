# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::Name;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    my $Code = $Self->_GetFileContents($Filename);

    my ($NameOfTag) = $Code =~ m/<Name>([^<>]+)<\/Name>/;
    my $NameOfFile = substr( basename($Filename), 0, -5 );    # cut off .sopm

    if ( $NameOfTag ne $NameOfFile ) {
        return $Self->DieWithError(<<EOF);
The module name $NameOfTag is not equal to the name of the .sopm file ($NameOfFile).
EOF
    }
}

1;
