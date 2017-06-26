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

        my @NavigationArray = split qr{::}, $NavigationContent;

        my %ValidToplevelEntries = (
            CloudService     => 1,
            Core             => 1,
            Daemon           => 1,
            GenericInterface => 1,
            Frontend         => 1,
        );

        if ( !$ValidToplevelEntries{ $NavigationArray[0] } ) {
            $ErrorMessage .= sprintf "'%s' is not one of the allowed top level navigation entries (%s)\n",
                $NavigationArray[0], join( ', ', sort keys %ValidToplevelEntries );
            $ErrorMessage .= "Line $Counter: $Line\n";
        }

        if ( $NavigationArray[0] eq 'Frontend' && $NavigationArray[1] ) {

            my %ValidFrontendEntries = (
                Admin    => 1,
                Agent    => 1,
                Base     => 1,
                Customer => 1,
                Public   => 1,
            );

            if ( !$ValidFrontendEntries{ $NavigationArray[1] } ) {
                $ErrorMessage .= sprintf "'%s' is not one of the allowed Frontend navigation entries (%s)\n",
                    $NavigationArray[1], join( ', ', sort keys %ValidFrontendEntries );
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }

        if ( $CurrentSettingName =~ m{::EventModule} ) {
            if (
                @NavigationArray != 3
                || $NavigationArray[0] ne 'Core'
                || $NavigationArray[1] ne 'Event'
                )
            {
                $ErrorMessage .= "Event handler registrations should be grouped in 'Core::Event::*'\n";
                $ErrorMessage .= "Line $Counter: $Line\n";

            }
        }

        # if ($CurrentSettingName =~ m{^Loader}) {
        #     if (
        #         @NavigationArray != 3
        #         || $NavigationArray[0] ne 'Frontend'
        #         || $NavigationArray[1] ne 'Base'
        #         || $NavigationArray[1] ne 'Loader'
        #     ) {
        #         $ErrorMessage .= "Loader settings should be grouped in 'Frontend::Base::Loader'\n";
        #         $ErrorMessage .= "Line $Counter: $Line\n";
        #     }
        # }

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
