# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::DTL::CGIHandle;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my $Counter;
    my $ErrorMessage;

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # allow IE workaround, e. g. <a href="$Env{"CGIHandle"}/$QData{"Filename"}?Action=...">xxx</a>
        if ( $Line =~ /<a.+href="\$Env\{"CGIHandle"\}[^\/](.*)>/ ) {
            $ErrorMessage .= __PACKAGE__ . "\n" . <<EOF;
\$Env{\"CGIHandle\"} is not allowed in <a>tags. Use \$Env{\"Baselink\"}!
Line $Counter: $Line
EOF
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
