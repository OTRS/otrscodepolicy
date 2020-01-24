# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::DateTime;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return       if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        # Look for code that uses not allowed date/time modules and functions
        if ( $Line =~ m{(use\s+(Date::Pcalc|Time::Local|Time::Piece)|\b(timelocal|gmtime|timegm)\s*\()}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Use of Date::Pcalc, Time::Local, Time::Piece, timelocal, gmtime and timegm is not allowed anymore. Use Kernel::System::DateTime instead.
    Please see http://doc.otrs.com/doc/manual/developer/6.0/en/html/package-porting.html#package-porting-5-to-6 for porting guidelines.
$ErrorMessage
EOF
    }

    return;
}

1;
