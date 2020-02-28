# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Lint;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub _build_cmd {
    return 'xmllint --noout --nonet';
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Command = sprintf( "%s %s %s 2>&1", $Self->cmd(), $Self->argv(), $Filename );
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
