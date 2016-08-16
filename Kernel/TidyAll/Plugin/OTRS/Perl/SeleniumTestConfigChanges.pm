# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::SeleniumTestConfigChanges;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

our $ObjectManagerDisabled = 1;

# Make sure Selenium tests only modify the configuration via $Helper->ConfigSettingChange().

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ m{->ConfigItemUpdate|->ConfigItemReset}smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<"EOF";
Selenium tests should modify the system configuration exclusively via
\$Helper->ConfigSettingChange() (it has the same API as ConfigSettingUpdate()).
This also makes "sleep" statements for mod_perl unneeded.
$ErrorMessage
EOF
    }

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ m{RestoreSystemConfiguration}smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<"EOF";
Please don't use the 'RestoreSystemConfiguration' flag any more.
$ErrorMessage
EOF
    }

    return;
}

1;
