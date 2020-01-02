# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::PerlConfigFileFormat;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    if ( $Code !~ m{^package \s}smx || $Code !~ m{^sub \s+ Load}smx ) {

        die __PACKAGE__ . "\n" . <<EOF;
Perl configuration files for OTRS 6+ must use the the new format like Kernel/Config/Files/ZZZAAuto.pm (they need to be created as a package with a Load() method).
EOF
    }

    return;
}

1;
