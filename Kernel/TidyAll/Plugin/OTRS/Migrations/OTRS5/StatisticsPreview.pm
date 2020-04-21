# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS5::StatisticsPreview;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 6, 0 );

    if ( $Code !~ m{^sub\sGetStat(Table|Element)Preview}smx ) {
        return $Self->DieWithError(<<"EOF");
The new statistics GUI provides a preview for the current configuration. This must be implemented
in the statistic modules and usually returns fake / random data for speed reasons. So for any
dynamic (matrix) statistic that provides the method GetStatElement() you should also add a method
GetStatElementPreview(), and for every dynamic (table) statistic that provides
GetStatTable() you should accordingly add GetStatTablePreview() Otherwise
the preview in the new statistics GUI will not work for your statistics. You can find example
implementations in the default OTRS statistics.

EOF
    }

    return;
}

1;
