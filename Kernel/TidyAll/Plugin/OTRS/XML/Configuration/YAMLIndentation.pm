# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::YAMLIndentation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin removes any unneeded indentation from YAML.

    ---
        Key:    Value
        SubHash:
            Subkey: Subvalue

will become:

    ---
    Key:    Value
    SubHash:
        Subkey: Subvalue

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 8, 0 );

    $Code =~ s{
        (<Item[^>]+ValueType="YAML"[^>]*>\s*<!\[CDATA\[---\n)
        (.*?)
        ^\s*(\]\]>)\s*(</Item>)}{
            $1.RemoveLeadingWhitespaces($2).$3.$4;
        }exmsg;

    return $Code;
}

sub RemoveLeadingWhitespaces {
    my ($YAMLString) = @_;

    return $YAMLString if !$YAMLString;

    my @Lines = split( m{\n}, $YAMLString );

    # Detect if we have an unneeded common indentation on all lines.
    my $CommonIndent = 1000;
    LINE:
    for my $Line (@Lines) {
        my ($Whitespace) = $Line =~ m{^(\s+)}xms;
        my $WhitespaceLength = length( $Whitespace // '' );
        $CommonIndent = $WhitespaceLength if $CommonIndent > $WhitespaceLength;
    }

    # Remove common indent if found.
    if ($CommonIndent) {
        @Lines = map { substr( $_, $CommonIndent ) } @Lines;
    }

    return join( "\n", @Lines ) . "\n";

}

1;
