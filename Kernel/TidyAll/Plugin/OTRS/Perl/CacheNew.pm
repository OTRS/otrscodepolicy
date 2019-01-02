# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::CacheNew;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

## nofilter(TidyAll::Plugin::OTRS::Perl::CacheNew)
## nofilter(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    $Code = $Self->StripPod( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m/Kernel::System::Cache->new/smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't create your own instance of Kernel::System::Cache.pm, but use $Kernel::OM->Get('Kernel::System::Cache') instead.
$ErrorMessage
EOF
    }

    return;
}

1;
