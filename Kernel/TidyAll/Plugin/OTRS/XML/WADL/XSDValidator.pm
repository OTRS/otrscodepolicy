# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::WADL::XSDValidator;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTRS::Base);

sub _build_cmd {
    my $XSDFile = dirname(__FILE__) . '/../../StaticFiles/XSD/WADL/wadl.xsd';
    return "xmllint --noout --nonet --schema $XSDFile";
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    my $Command = sprintf( "%s %s %s 2>&1", $Self->cmd(), $Self->argv(), $Filename );
    my $Output  = `$Command`;

    if ( ${^CHILD_ERROR_NATIVE} ) {
        die __PACKAGE__ . "\n$Output\n";    # non-zero exit code
    }
}

1;
