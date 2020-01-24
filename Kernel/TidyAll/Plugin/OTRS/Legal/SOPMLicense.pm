# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Legal::SOPMLicense;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace license with GPL3
    $Code
        =~ s{<License> .*? </License>}{<License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>}gsmx;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 2, 4 );

    if ( $Code !~ m{<License> .+? </License>}smx ) {
        die __PACKAGE__ . "\nCould not find a valid OPM license header.";
    }

    if (
        $Code
        !~ m{<License>GNU \s GENERAL \s PUBLIC \s LICENSE \s Version \s 3, \s 29 \s June \s 2007</License>}smx
        )
    {
        die __PACKAGE__ . "\n" . <<EOF;
Invalid license found.
Use <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>.
EOF
    }

    return;
}

1;
