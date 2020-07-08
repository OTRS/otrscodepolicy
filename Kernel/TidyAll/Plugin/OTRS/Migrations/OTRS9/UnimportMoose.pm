# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 9, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 10, 0 );

    # Moose Roles
    if ( $Code =~ m{^use \s+ Moose::Role}smx ) {
        return $Code if $Code =~ m{^no \s+ Moose::Role}smx;
        $Code =~ s{1;\n\Z}{no Moose::Role;\n\n1;\n}smx;

    }

    # Normal Moose objects
    elsif ( $Code =~ m{^use \s+ Moose}smx ) {
        return $Code if $Code =~ m{^no \s+ Moose}smx;
        $Code =~ s{1;\n\Z}{no Moose;\n\n1;\n}smx;
    }

    return $Code;
}

1;
