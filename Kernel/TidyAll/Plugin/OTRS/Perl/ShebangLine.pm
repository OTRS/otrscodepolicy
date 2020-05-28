# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ShebangLine;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    if ( substr( $Code, 0, 15 ) eq '#!/usr/bin/perl' ) {
        $Code =~ s{\A\#!/usr/bin/perl.*?$}{#!/usr/bin/env perl}xms;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    # Check for presence of the correct shebang line.
    if ( substr( $Code, 0, 20 ) ne "#!/usr/bin/env perl\n" ) {
        return $Self->DieWithError(<<"EOF");
Please change the shebang line to '#!/usr/bin/env perl'.
EOF
    }

    return;
}

1;
