# --
# TidyAll/Plugin/OTRS/DTL/Select.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::DTL::Select;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    my ( $Counter, $ErrorMessage );

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # look for forbidden selects that are not one-line, empty selects
        if ( $Line =~ /<select/ && $Line !~ /<option/ && $Line !~ /<[\/]select/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Use Layout::BuildSelection instead of select elements in the DTL files.
$ErrorMessage
EOF
    }

    return;
}

1;
