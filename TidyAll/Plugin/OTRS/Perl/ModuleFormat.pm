package TidyAll::Plugin::OTRS::Perl::ModuleFormat;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    # Check for absense of shebang line
    if ( $Code =~ m{\A\#!}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Perl modules should not have a shebang line (#!/usr/bin/perl).
EOF
    }

    return;
}

1;
