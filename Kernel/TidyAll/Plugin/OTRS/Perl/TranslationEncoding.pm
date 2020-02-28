# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::TranslationEncoding;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 4, 0 );

    if ( $Code !~ m{^[ \t]*use\s+utf8;}mx ) {
        return $Self->DieWithError(<<EOF);
All language files must be encoded in "utf-8", and include the "use utf8;" Perl pragma.
EOF
    }

    return;
}

1;
