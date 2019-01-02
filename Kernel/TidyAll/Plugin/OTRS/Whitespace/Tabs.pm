# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Whitespace::Tabs;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter = 1;
    my $ErrorMessage;

    #
    # Check for stray tabs
    #
    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        $Counter++;

        if ( $Line =~ m/\t/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }

    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Please substitute all tabulators with four spaces.
$ErrorMessage
EOF
    }
}

1;
