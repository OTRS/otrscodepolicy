# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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
