# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ProhibitObjectManager;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    if ( $Code =~ m{\$Kernel::OM}smx ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use \$Kernel::OM in Kernel::WebApp, except in controllers.
EOF
    }

    return;
}

1;
