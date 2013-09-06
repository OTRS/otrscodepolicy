# --
# TidyAll/Plugin/OTRS/Whitespace/TrailingWhitespace.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Whitespace::TrailingWhitespace;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Remove trailing spaces at end of lines
    $Code =~ s/^(.+?)[ ]+\n/$1\n/xmsg;

    # Remove empty trailing lines
    $Code =~ s/\n(\s|\n)+\z/\n/xmsg;

    return $Code;
}

1;
