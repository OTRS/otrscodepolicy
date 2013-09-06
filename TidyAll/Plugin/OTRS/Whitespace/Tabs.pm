# --
# TidyAll/Plugin/OTRS/Whitespace/Tabs.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Whitespace::Tabs;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $LineCounter = 1;
    my $Errors;

    #
    # Check for stray tabs
    #
    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        if ( $Line =~ m/\t/ ) {
            $Errors .= "TabsCheck: tabulators used in line $LineCounter, please remove.\n";
        }

        $LineCounter++;
    }

    die $Errors if ($Errors);
}

1;
