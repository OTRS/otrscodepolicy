package TidyAll::Plugin::OTRS::TabsCheck;

use strict;
use warnings;

BEGIN {
  $TidyAll::Plugin::OTRS::TabsCheck::VERSION = '0.1';
}
use Moo;
extends 'Code::TidyAll::Plugin';

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;


    my $LineCounter = 1;
    my $Errors;

    #
    # Check for stray tabs
    #
    LINE:
    for my $Line ( split(/\n/, $Code) ) {

        if ($Line =~ m/\t/) {
            $Errors .= "TabsCheck: tabulators used in line $LineCounter, please remove.\n";
        }

        $LineCounter++;
    }

    die $Errors if ($Errors);
}

1;
