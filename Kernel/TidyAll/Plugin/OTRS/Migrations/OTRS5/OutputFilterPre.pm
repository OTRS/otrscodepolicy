# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS5::OutputFilterPre;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

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
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
