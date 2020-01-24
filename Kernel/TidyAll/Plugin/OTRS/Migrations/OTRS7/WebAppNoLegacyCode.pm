# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS7::WebAppNoLegacyCode;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my @ForbiddenPaths = qw(
        Kernel::Output::HTML
        Kernel::Modules
    );

    my @ErrorPaths;

    for my $ForbiddenPath (@ForbiddenPaths) {
        if ( $Code =~ m{$ForbiddenPath} ) {
            push @ErrorPaths, $ForbiddenPath;
        }
    }

    if (@ErrorPaths) {
        my $ErrorPathJoin = join( ' or ', @ErrorPaths );
        die __PACKAGE__ . "\n" . <<EOF;
Don't use legacy code from $ErrorPathJoin in Kernel::WebApp.
EOF
    }

    return;
}

1;
