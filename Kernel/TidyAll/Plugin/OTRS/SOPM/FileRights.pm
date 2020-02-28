# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::FileRights;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ExecutablePermissionCheck = qr{Permission="760"};
    my $StaticPermissionCheck     = qr{Permission="660"};
    my $Explanation = 'A <File>-Tag has wrong permissions. Script files normally need 760 rights, the others 660.';

    # A little more lenient before OTRS 8 (with group executable permissions)
    if ( $Self->IsFrameworkVersionLessThan( 8, 0 ) ) {
        $ExecutablePermissionCheck = qr{Permission="770"};
        $StaticPermissionCheck     = qr{Permission="660"};
        $Explanation = 'A <File>-Tag has wrong permissions. Script files normally need 770 rights, the others 660.';
    }

    # A lot more lenient before OTRS 6 (world permissions)
    if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
        $ExecutablePermissionCheck = qr{Permission="755"};
        $StaticPermissionCheck     = qr{Permission="644"};
        $Explanation = 'A <File>-Tag has wrong permissions. Script files normally need 755 rights, the others 644.';
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
        return $Self->DieWithError(<<EOF);
$Explanation
$ErrorMessage
EOF
    }

    return;
}

1;
