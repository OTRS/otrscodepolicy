# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::FileNameUnitTest;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $Code = $Self->_GetFileContents($Filename);
    my $NameOfFile = substr( basename($Filename), 0, -3 ); # cut off .js

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{^([^= ]+)\s*=\s*\(function\s*\(Namespace\)\s*\{ }xms ) {

            if ( $1 . ".UnitTest" ne $NameOfFile ) {
                die __PACKAGE__ . "\n" . <<EOF;
The file name ($NameOfFile.js) is not correct for the unit tests of the JavaScript namespace ($1). Must be $1.UnitTest.js.
EOF
            }
        }
    }

}

1;
