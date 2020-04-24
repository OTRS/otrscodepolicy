# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::WSDL::XSDValidator;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    # read the file as an array
    open FH, "$Filename" or die $!;    ## no critic
    my $String = do { local $/ = undef; <FH> };
    close FH;

    my $LiteralStyle;

    # check if WSDL file uses Literal messages
    if ( $String =~ m{<soap:body \s+ use="literal"}msxi ) {
        $LiteralStyle = 1;
    }

    # generate the XMLLint command based on the style of WSDL
    my $XSDDir = dirname(__FILE__) . '/../../StaticFiles/XSD/WSDL/';

    my $XSDFile = 'WSDL.xsd';
    if ($LiteralStyle) {
        $XSDFile = 'Literal.xsd';
    }

    my $CMD = "xmllint --noout --nonet --nowarning --schema $XSDDir$XSDFile";

    my $Command = sprintf( "%s %s %s 2>&1", $CMD, $Self->argv(), $Filename );
    my $Output  = `$Command`;

    # If execution failed, warn about installing package.
    if ( ${^CHILD_ERROR_NATIVE} == -1 ) {
        return $Self->DieWithError("'xmllint' was not found, please install it.\n");
    }

    if ( ${^CHILD_ERROR_NATIVE} ) {
        return $Self->DieWithError("$Output\n");    # non-zero exit code
    }
}

1;
