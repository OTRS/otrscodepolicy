# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::FileRights;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ExecutablePermissionCheck = qr{Permission="[75]{2}0"};
    my $StaticPermissionCheck     = qr{Permission="[64]{2}0"};

    # A little more lenient before OTRS 6 (world permissions)
    if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
        $ExecutablePermissionCheck = qr{Permission="[750]{3}"};
        $StaticPermissionCheck     = qr{Permission="[640]{3}"};
    }


    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line !~ m/<File.*\/>/;
        if ( $Line =~ m/<File.*Location="([^"]+)".*\/>/ ) {
            if ( $1 && $1 =~ /\.(pl|sh|fpl|psgi|sh)$/ ) {
                if ( $Line !~ $ExecutablePermissionCheck ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }

            else {
                if ( $Line !~ $StaticPermissionCheck ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
A <File>-Tag has wrong permissions. Script files normally need 750 rights, the others 640.
$ErrorMessage
EOF
    }

    return;
}

1;
