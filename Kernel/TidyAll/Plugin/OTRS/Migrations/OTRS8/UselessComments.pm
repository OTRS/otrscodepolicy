# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS8::UselessComments;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 8, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 9, 0 );

    my @CleanupRegexes = (
        qr{^[ ]* [#] [ ]+ (?: [gG]et | [cC]heck ) [ ] needed [ ] (?:objects|variables|stuff|params|data) [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] [a-zA-Z0-9_]{2,} [ ] object [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] script [ ] alias [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] valid [ ] list [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [aA]llocate [ ] new [ ] hash [ ] for [ ] object [.]? \n}smx,
    );

    for my $Regex (@CleanupRegexes) {
        $Code =~ s{$Regex}{}smxg;
    }

    return $Code;
}

1;
