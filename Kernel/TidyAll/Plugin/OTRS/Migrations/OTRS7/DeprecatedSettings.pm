# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my ( $Counter, $ErrorMessage );

    my $CurrentSettingName;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line !~ m{<Setting\s+Name="(.*?)"}smx;

        $CurrentSettingName = $1;

        my @Rules = (
            {
                Name             => 'Obsolete frontend setting',
                MatchSettingName => qr{^(Customer|Public)Frontend::},
                ErrorMessage =>
                    'Obsolete frontend setting, (Public|Customer)Frontend not allowed anymore.',
            },
            {
                Name             => 'Obsolete loader setting',
                MatchSettingName => qr{^Loader::(Customer|Public)},
                ErrorMessage =>
                    'Obsolete loader setting, Loader::(Customer|Public) not allowed anymore.',
            },
            {
                Name             => 'Obsolete loader module setting',
                MatchSettingName => qr{^Loader::Module::(Customer|Public)},
                ErrorMessage =>
                    'Obsolete loader module setting, Loader::Module::(Customer|Public) not allowed anymore.',
            },
            {
                Name             => 'Obsolete search router setting',
                MatchSettingName => qr{^Frontend::Search},
                ErrorMessage =>
                    'Obsolete search router setting, Frontend::Search not allowed anymore.',
            },
        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};

            if (
                $Rule->{SkipForFrameworkVersionLessThan}
                && $Self->IsFrameworkVersionLessThan( @{ $Rule->{SkipForFrameworkVersionLessThan} } )
                )
            {
                next RULE;
            }

            $ErrorMessage
                .= "Deprecated setting found $CurrentSettingName: $Rule->{ErrorMessage}\n";
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Problems were found in the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
