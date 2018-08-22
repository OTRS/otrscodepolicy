# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Docbook::RemoveContactChapter;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # remove chapter
    $Code =~ s{
        <chapter> \s*
        (?:
            <!-- \s+ \*+ \s+ --> \s+
            <!-- \s+ \d+ \. \s+ \w+ \s+ --> \s+
            <!-- \s+ \*+ \s+ --> \s+
        |
        )
        <title> [ ]* (?: Contact | Contacts | Kontakt ) [ ]* <\/title>
        ( (?! <\/chapter> ). )* <\/chapter> [ \n]*
    }{}xms;

    return $Code;
}

1;
