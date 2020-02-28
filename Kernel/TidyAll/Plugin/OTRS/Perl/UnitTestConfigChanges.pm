# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::UnitTestConfigChanges;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

our $ObjectManagerDisabled = 1;

# Make sure Selenium tests only modify the configuration via $Helper->ConfigSettingChange().

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    # use only for Selenium tests prior to OTRS 6
    if (
        $Code !~ m{/Selenium/}smx
        && $Self->IsFrameworkVersionLessThan( 6, 0 )
        )
    {
        return;
    }

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ m{->ConfigItemUpdate|->ConfigItemReset}smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
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
        return $Self->DieWithError(<<"EOF");
Please don't use the 'RestoreSystemConfiguration' flag any more.
$ErrorMessage
EOF
    }

    return;
}

1;
