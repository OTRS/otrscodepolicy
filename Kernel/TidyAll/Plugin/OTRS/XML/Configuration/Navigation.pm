# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::Navigation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    my $CurrentSettingName;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m{<Setting\s+Name="(.*?)"}smx ) {
            $CurrentSettingName = $1;
        }
        my ($NavigationContent) = $Line =~ m{<Navigation>(.*?)</Navigation>}smx;

        next LINE if !$NavigationContent;

        my @Rules = (
            {
                Name                   => 'Valid toplevel entries',
                MatchSettingName       => qr{.*},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^(CloudService|Core|Daemon|GenericInterface|Frontend)(::|$)},
                ErrorMessage =>
                    'Invalid top level group found (only CloudService|Core|Daemon|GenericInterface|Frontend are allowed).',
            },
            {
                Name                 => 'Valid Frontend subgroups',
                MatchSettingName     => qr{.*},
                MatchNavigationValue => qr{^Frontend},                # no entries allowed in "Frontend" directly
                RequireNavigationMatch => qr{^Frontend::(Admin|Agent|Base|Customer|Public)(::|$)},
                ErrorMessage =>
                    'Invalid top Frontend subgroup found (only Admin|Agent|Base|Customer|Public are allowed).',
            },
            {
                Name                   => 'Event handlers',
                MatchSettingName       => qr{::EventModule},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Core::Event::},
                ErrorMessage           => "Event handler registrations should be grouped in 'Core::Event::*.",
            },
            {
                Name                   => 'Main Loader config',
                MatchSettingName       => qr{^Loader::(Agent|Customer|Enabled)},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Base::Loader},
                ErrorMessage           => "Main Loader settings should be grouped in 'Frontend::Base::Loader'.",
            },

        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};
            next RULE if $NavigationContent !~ $Rule->{MatchNavigationValue};

            if ( $NavigationContent !~ $Rule->{RequireNavigationMatch} ) {
                $ErrorMessage
                    .= "Invalid navigation value found for setting $CurrentSettingName: $Rule->{ErrorMessage}\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Problems were found in the navigation structure of the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
