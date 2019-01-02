# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Whitespace::TrailingWhitespace;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Remove trailing spaces at end of lines
    $Code =~ s/^(.*?)[ ]+\n/$1\n/xmsg;

    # Remove empty trailing lines
    $Code =~ s/\n(\s|\n)+\z/\n/xmsg;

    return $Code;
}

1;
