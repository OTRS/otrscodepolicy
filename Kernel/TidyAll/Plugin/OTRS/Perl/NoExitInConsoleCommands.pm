# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::NoExitInConsoleCommands;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{ (^|\s+) exit (;|\s|\() }smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<EOF);
Don't use 'exit' in console commands, use 'return \$Self->ExitCodeOk();' or 'return \$Self->ExitCodeError();' instead.
$ErrorMessage
EOF
    }

    return;
}

1;
