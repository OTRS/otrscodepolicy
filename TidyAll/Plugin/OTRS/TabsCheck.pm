package TidyAll::Plugin::OTRS::TabsCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::PluginBase);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->is_disabled(Code => $Code);

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
