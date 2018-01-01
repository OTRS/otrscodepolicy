# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS5::StatisticsPreview;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    if ( $Code !~ m{^sub\sGetStat(Table|Element)Preview}smx ) {
        die __PACKAGE__ . "\n" . <<EOF;
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
