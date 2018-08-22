# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ForeachToFor;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    # The following test matches only for a foreach without a "#" in the
    # beginning of a line. The foreach has to be the first expression in a
    # line, spaces do not matter. The foreach is replaced with for.
    # Comments and other lines with other chars before the foreach are
    # ignored.

    $Code =~ s{^ ([^#] \s{0,200}) foreach (.*?) }{$1for$2}xmsg;

    return $Code;
}

1;
