# --
# TidyAll/Plugin/OTRS/DTL/Baselink.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::DTL::Baselink;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin verifies that $Env{"Baselink"} is not used in form tags.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my $Counter;
    my $ErrorMessage;

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ /<form.+action="\$Env{"Baselink"}"/i ) {
            $ErrorMessage .= __PACKAGE__ . "\n" . <<EOF;
\$Env{\"Baselink\"} is not allowed in <form>tags. Use \$Env{\"CGIHandle\"}!
Line $Counter: $Line
EOF
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
