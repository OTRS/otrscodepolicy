# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl;

use strict;
use warnings;

use Scalar::Util;
use TidyAll::OTRS;
use Pod::Strip;

use parent qw(TidyAll::Plugin::OTRS::Base);

# Process Perl code and replace all Pod sections with comments.
sub StripPod {
    my ( $Self, %Param ) = @_;

    my $PodStrip = Pod::Strip->new();
    $PodStrip->replace_with_comments(1);
    my $Code;
    $PodStrip->output_string( \$Code );
    $PodStrip->parse_string_document( $Param{Code} );
    return $Code;
}

sub StripComments {
    my ( $Self, %Param ) = @_;

    my $Code = $Param{Code};
    $Code =~ s/^ \s* \# .*? $/\n/smxg;
    return $Code;
}

1;
