# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator;

use strict;
use warnings;

use File::Basename;
use Capture::Tiny qw(capture_merged);
use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    # Default: OTRS 6+ configuration files in Kernel/Config/Files/XML.
    my $XSDFile   = dirname(__FILE__) . '/../../StaticFiles/XSD/Configuration.xsd';
    my $WantedDir = 'Kernel/Config/Files/XML';

    # Handling for older versions: config files in Kernel/Config/Files.
    if ( $Self->IsFrameworkVersionLessThan( 5, 0 ) ) {

        # In OTRS 4 and below there were special CSS_IE7 and CSS_IE8 Tags for the loader.
        $XSDFile   = dirname(__FILE__) . '/../../StaticFiles/XSD/Configuration_before_5.xsd';
        $WantedDir = 'Kernel/Config/Files';
    }
    elsif ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
        $XSDFile   = dirname(__FILE__) . '/../../StaticFiles/XSD/Configuration_before_6.xsd';
        $WantedDir = 'Kernel/Config/Files';
    }

    if ( $Filename !~ m{$WantedDir/[^/]+[.]xml$}smx ) {
        die __PACKAGE__ . "\nConfiguration file $Filename does not exist in the correct directory $WantedDir.\n";
    }

    my $Command = sprintf( "xmllint --noout --nonet --schema %s %s %s", $XSDFile, $Self->argv(), $Filename );
    my ( $Output, @Result ) = capture_merged { system($Command) };

    # If execution failed, warn about installing package.
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
