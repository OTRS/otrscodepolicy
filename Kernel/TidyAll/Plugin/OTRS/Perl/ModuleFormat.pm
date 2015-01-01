# --
# TidyAll/Plugin/OTRS/Perl/ModuleFormat.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ModuleFormat;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check for absense of shebang line
    if ( $Code =~ m{\A\#!}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Perl modules should not have a shebang line (#!/usr/bin/perl).
EOF
    }

    return;
}

1;
