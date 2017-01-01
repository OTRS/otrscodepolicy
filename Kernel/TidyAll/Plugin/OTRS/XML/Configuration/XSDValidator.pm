# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator;

use strict;
use warnings;

use File::Basename;
use Capture::Tiny qw(capture_merged);
use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    my $XSDFile = dirname(__FILE__) . '/../../StaticFiles/XSD/Configuration.xsd';

    # In OTRS 4 and below there were special CSS_IE7 and CSS_IE8 Tags for the loader.
    if ( $Self->IsFrameworkVersionLessThan( 5, 0 ) ) {
        $XSDFile = dirname(__FILE__) . '/../../StaticFiles/XSD/Configuration_before_5.xsd';
    }

    my $Command = sprintf( "xmllint --noout --nonet --schema %s %s %s", $XSDFile, $Self->argv(), $Filename );
    my ( $Output, @Result ) = capture_merged { system($Command) };

    # if execution failed, warn about installing package
    if ( $Result[0] == -1 ) {
        print STDERR "'xmllint' is not installed.\n";
        print STDERR
            "You can install this using 'apt-get install libxml2-utils' package on Debian-based systems.\n\n";
    }

    if ( @Result && $Result[0] ) {
        die __PACKAGE__ . "\n$Output\n";    # non-zero exit code
    }
}

1;
