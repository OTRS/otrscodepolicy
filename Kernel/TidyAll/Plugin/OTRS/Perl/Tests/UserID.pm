# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Tests::UserID;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 8, 0 );

    # Don't use hardcoded UserID => 1 in tests, but the provided unit test system user attribute instead.
    $Code =~ s{\b((?:Change)?UserID\s*=>\s*)1\b}{$1\$Self->SystemUserID()}smxg;

    return $Code;
}

1;
