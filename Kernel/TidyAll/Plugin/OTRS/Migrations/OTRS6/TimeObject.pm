# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeObject;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);
## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::TimeObject)

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return       if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{Kernel::System::Time[^a-zA-Z]}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<EOF);
Use of deprecated Kernel::System::Time is not allowed anymore except for legacy API interfaces. Please use Kernel::System::DateTime instead.
    Please see http://doc.otrs.com/doc/manual/developer/6.0/en/html/package-porting.html#package-porting-5-to-6 for porting guidelines.
$ErrorMessage
EOF
    }

    return;
}

1;
