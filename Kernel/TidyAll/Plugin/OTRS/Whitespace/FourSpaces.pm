# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Whitespace::FourSpaces;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter;
    my $ErrorMessage;
    my $IsTextArea = 0;    # in config files
    my $IsSOPMData = 0;    # database entries of sopm files

    #
    # Check for steps of four spaces
    #
    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        $Counter++;

        # textareas in config files
        if ( $Line =~ /<TextArea>/ ) {
            $IsTextArea = 1;
        }
        if ( $Line =~ /<\/TextArea>/ ) {
            $IsTextArea = 0;
        }

        # database entries of sopm files
        if ( $Line =~ m{ <Data \s}smx ) {
            $IsSOPMData = 1;
        }
        if ( $Line =~ m{ < \/ Data > }smx ) {
            $IsSOPMData = 0;
        }

        if ( $Line =~ /^( +)/ ) {
            my $SpaceString = $1;
            my $Length      = length $SpaceString;

            if ( $Length % 4 && !$IsTextArea && !$IsSOPMData ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Spaces at the beginning of a line should be in steps of four!
$ErrorMessage
EOF
    }
}

1;
