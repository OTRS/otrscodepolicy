# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Translatable;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    if ( $Code =~ m{Translatable\(}xms && $Code !~ m{^use\s+Kernel::Language[^\n]+Translatable}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
The code uses Kernel::Language::Translatable(), but does not import it to the current package. Please add:
use Kernel::Language qw(Translatable);
EOF
    }

    return;
}

1;
