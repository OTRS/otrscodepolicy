# --
# TidyAll/Plugin/OTRS/Perl/DieExit.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::DieExit;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{^ \s* (die|exit) (;|\s|\() }smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use 'die' and 'exit' in modules.
$ErrorMessage
EOF
    }

    return;
}

1;
