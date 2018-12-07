# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::FileName;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $Code       = $Self->_GetFileContents($Filename);
    my $NameOfFile = substr( basename($Filename), 0, -3 );    # cut off .js

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{^([^= ]+)\s*=\s*\(function\s*\(TargetNS\)\s*\{ }xms ) {

            if ( $1 ne $NameOfFile && $Line !~ m{^//} ) {
                die __PACKAGE__ . "\n" . <<EOF;
The file name ($NameOfFile.js) is not equal to the name of the JavaScript namespace ($1).
EOF
            }
        }
    }
}

1;
