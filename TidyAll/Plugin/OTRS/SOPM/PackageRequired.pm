# --
# TidyAll/Plugin/OTRS/SOPM/PackageRequired.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::PackageRequired;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if ( $Self->IsFrameworkVersionLessThan( 3, 1 ) );

    if ( $Code =~ m{<PackageRequired>}smx ) {
        die __PACKAGE__ . "\n" . <<EOF;
You use the attribute PackageRequired without a version tag.
Use: \"<PackageRequired Version="1.1.1">NewPackage</PackageRequired>
EOF
    }
}

1;
