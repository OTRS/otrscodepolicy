# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Legal::SOPMLicense;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace GPL2 with AGPL3
    $Code
        =~ s{<License>GNU \s GENERAL \s PUBLIC \s LICENSE \s Version \s 2, \s June \s 1991</License>}{<License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>}gsmx;

    return $Code;
}

sub validate_source {     ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 2, 4 );

    if ( $Code !~ m{<License> .+? </License>}smx ) {
        die __PACKAGE__ . "\nCould not find a license header."
    }

    if (
        $Code
        !~ m{<License>GNU \s AFFERO \s GENERAL \s PUBLIC \s LICENSE \s Version \s 3, \s November \s 2007</License>}smx
        )
    {
        die __PACKAGE__ . "\n" . <<EOF;
Invalid license found.
Use <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>.
EOF
    }

    return;
}

1;
