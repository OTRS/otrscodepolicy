package TidyAll::Plugin::OTRS::Whitespace::TrailingWhitespace;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    # Remove trailing spaces at end of lines
    $Code =~ s/^(.+?)[ ]+\n/$1\n/xmsg;

    # Remove empty trailing lines
    $Code =~ s/\n(\s|\n)+\z/\n/xmsg;

    return $Code;
}

1;
