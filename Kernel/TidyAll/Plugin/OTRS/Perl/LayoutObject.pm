# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::LayoutObject;
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );
    return if !$Self->IsFrameworkVersionLessThan( 6, 0 );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    my $Forbidden = qr{LayoutObject|Kernel::Output::HTML::Layout}xms;
    if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
        $Forbidden = qr{LayoutObject}xms;
    }

    if ( $Code =~ $Forbidden ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use the LayoutObject in bin/ or in Kernel/System.
EOF
    }

    return;
}

1;
