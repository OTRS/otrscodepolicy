# --
# TidyAll/Plugin/OTRS/SQL/ColumnTypes.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SQL::ColumnTypes;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter );

    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ /<Column.+?Type="(.+?)".*?\/>/i ) {
            if ( $1 !~ /^(DATE|SMALLINT|BIGINT|INTEGER|DECIMAL|VARCHAR|LONGBLOB)$/i ) {
                $ErrorMessage .= "You try to use a unknown data type '$1'\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . <<EOF;
$ErrorMessage
Allowed are DATE, SMALLINT, BIGINT, INTEGER, DECIMAL, VARCHAR, LONGBLOB.
EOF
    }
}

1;
