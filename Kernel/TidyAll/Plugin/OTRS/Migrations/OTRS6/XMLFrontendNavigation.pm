# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::XMLFrontendNavigation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return       if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    my ( $CurrentSettingName, $InValue, $ValueContent );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m{<Setting\s+Name="(.*?)"}smx ) {
            $CurrentSettingName = $1;
            $InValue            = 0;
            $ValueContent       = '';
        }

        $InValue = 1 if $Line =~ m{<Value>};
        $ValueContent .= "\n" . $Line if $InValue;
        $InValue = 0 if $Line =~ m{</Value>};

        next LINE if !$ValueContent || $InValue;

        my @Rules = (
            {
                Name                     => 'Valid toplevel entries',
                MatchSettingName         => qr{^(Customer|Public)?Frontend::Navigation###.*},
                RequireValueContentMatch => qr{<Array>.*<DefaultItem[^>]+ValueType="FrontendNavigation"}sm,
            },
        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};

            if ( $ValueContent !~ $Rule->{RequireValueContentMatch} ) {
                $ErrorMessage
                    .= "Incorrect main menu registration found in setting $CurrentSettingName:$ValueContent\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Problems were found in the structure of the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
