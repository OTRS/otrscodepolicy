# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS5::OutputFilterPre;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 6, 0 );

    my @InvalidSettings;

    $Code =~ s{
        (<ConfigItem\s*Name="Frontend::Output::FilterElementPre.*?>)
    }{
        push @InvalidSettings, $1;
    }smxge;

    my $ErrorMessage;

    if (@InvalidSettings) {
        $ErrorMessage .= "Pre output filters are not supported in OTRS 5+.\n";
        $ErrorMessage .= "Wrong settings found: " . join( ', ', @InvalidSettings ) . "\n";
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
