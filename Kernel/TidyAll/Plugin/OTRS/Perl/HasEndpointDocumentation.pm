# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::HasEndpointDocumentation;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    if (
        $Code =~ m{^package [ ]+ Kernel::WebApp::Controller::API::}smx
        && $Code =~ m{^sub [ ]+ (?:Description|ExampleResponses)}smx
        && $Code !~ m{^with .+? Kernel::WebApp::Controller::API::Role::HasEndpointDocumentation .+?;}smx
        )
    {
        die __PACKAGE__ . "\n" . <<EOF;

You added endpoint documentation related subroutines to your endpoint, but didn't declare the needed role.

Please add the following role to your with-statement:

Kernel::WebApp::Controller::API::Role::HasEndpointDocumentation

EOF
    }

    return;
}

1;
