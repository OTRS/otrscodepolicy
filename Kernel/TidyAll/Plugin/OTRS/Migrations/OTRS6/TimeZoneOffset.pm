# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeZoneOffset;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Look for code that might contain old time zone offset calculations
        if (
            $Line =~ m{(timezone|time zone)}smi
            && $Line =~ m{3600}smi
            )
        {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        print __PACKAGE__ . "\n" . <<EOF;
Code might contain deprecated time zone offset calculations. Only use methods provided by Kernel::System::DateTime to change time zones and calculate date/time .
$ErrorMessage
EOF
    }

    return;
}

1;
