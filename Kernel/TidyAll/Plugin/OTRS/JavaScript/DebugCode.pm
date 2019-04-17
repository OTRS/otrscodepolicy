# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::DebugCode;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;
        if ( $Line =~ m{ console\.log\( }xms ) {
            $ErrorMessage
                .= "ERROR: JavaScript debug check found a console.log() statement in line( $Counter ): $Line\n";
            $ErrorMessage .= "This will break IE and Opera. Please remove it from your code.\n";
        }
        if ( $Line =~ m{ \bxit\( }xms ) {
            $ErrorMessage
                .= "ERROR: JavaScript debug check found a skipped test 'xit()' statement in line( $Counter ): $Line\n";
            $ErrorMessage .= "If the test is no longer necessary, please remove it from your code.\n";
        }
    }
    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
