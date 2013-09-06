# --
# TidyAll/Plugin/OTRS/SOPM/DocumentationPresent.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::DocumentationPresent;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    my $DocumentationPresent = $Code =~ m{^\s*<File.+Location="doc/(?:de|en)}smx;

    if ( !$DocumentationPresent ) {
        die __PACKAGE__ . "\nEvery OPM package needs to include documentation!";
    }
}

1;
