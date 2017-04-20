# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Docbook::ImageOutput;

use strict;
use warnings;

use File::Basename;
use Capture::Tiny qw(capture_merged);
use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Make sure images are correctly embedded, showing in original size and capped at
    #   available with. Forbid manual scaling.

    # See http://www.sagehill.net/docbookxsl/ImageSizing.html:
    # "To keep a graphic for printed output at its natural size unless it is too large to fit
    #   the available width, in which case shrink it to fit, use scalefit="1", width="100%",
    #   and contentdepth="100%" attributes."

    $Code
        =~ s{<graphic [^>]+ (fileref="[^">]+")[^>/]*(/?)>}{<graphic $1 scalefit="1" width="100%" contentdepth="100%"$2>}msxg;

    return $Code;
}

1;
