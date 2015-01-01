# --
# TidyAll/Plugin/OTRS/Perl/LayoutObject.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::LayoutObject;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    if ( $Code =~ m{LayoutObject}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use the LayoutObject in bin/ or in Kernel/System.
EOF
    }
    return;
}

1;
