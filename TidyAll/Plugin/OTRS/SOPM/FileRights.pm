# --
# TidyAll/Plugin/OTRS/SOPM/FileRights.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::FileRights;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line !~ m/<File.*\/>/;
        if ( $Line =~ m/<File.*Location="([^"]+)".*\/>/ ) {
            if ( $1 && $1 =~ /\.(pl|sh|fpl|psgi|sh)$/ ) {
                if ( $Line !~ /Permission="[750]{3}"/ ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }

            else {
                if ( $Line !~ /Permission="[640]{3}"/ ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
A <File>-Tag has wrong permissions. Script files normally need 755 rights, the others 644.
$ErrorMessage
EOF
    }

    return;
}

1;
