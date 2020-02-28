# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::WebApp::HeadGetWithoutBody;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 7, 0 );

    if ( $Code =~ m/^sub\s+RequestMethods[^}]+(get|head)[^}]+\}/xms && $Code =~ m{^sub\s+ValidationJSONBodyFields}xms )
    {
        return $Self->DieWithError(<<EOF);
Endpoints using the HEAD or GET request methods may not use a body payload. Use query params instead.
EOF
    }

    return;
}

1;
