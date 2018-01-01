# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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

    #$Code = $Self->StripPod( Code => $Code );
    #$Code = $Self->StripComments( Code => $Code );

    if ( $Code =~ m{Translatable\(}xms && $Code !~ m{^use\s+Kernel::Language[^\n]+Translatable}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
The code uses Kernel::Language::Translatable(), but does not import it to the current package. Please add:
use Kernel::Language qw(Translatable);
EOF
    }

    return;
}

1;
