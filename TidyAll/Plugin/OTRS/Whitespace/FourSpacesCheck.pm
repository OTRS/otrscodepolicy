package TidyAll::Plugin::OTRS::Whitespace::FourSpacesCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    my $LineCounter = 1;
    my $Errors;
    my $IsTextArea  = 0; # in config files
    my $IsSOPMData      = 0; # database entries of sopm files

    #
    # Check for steps of four spaces
    #
    LINE:
    for my $Line ( split(/\n/, $Code) ) {

        # textareas in config files
        if ($Line =~ /<TextArea>/) {
            $IsTextArea = 1;
        }
        if ($Line =~ /<\/TextArea>/) {
            $IsTextArea = 0;
        }

        # database entries of sopm files
        if ($Line =~ m{ <Data \s}smx ) {
            $IsSOPMData = 1;
        }
        if ($Line =~ m{ < \/ Data > }smx ) {
            $IsSOPMData = 0;
        }

        if ($Line =~ /^( +)/) {
            my $SpaceString = $1;
            my $Length = length $SpaceString;

            if ($Length % 4 && !$IsTextArea && !$IsSOPMData) {
                $Errors .= "Spaces at the beginning of a line should be in steps of four, error in line $LineCounter.\n"
            }
        }

        $LineCounter++;
    }

    die $Errors if ($Errors);
}

1;