# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::SubDeclaration;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

=head1 SYNOPSIS

This module checks for sub declarations with the brace in the following
line and corrects them.

    sub abc
    {
        ...
    }

will become:

    sub abc {
        ...
    }

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    if ( $Code =~ m|^sub \s+ \w+ \s* \r?\n \{ |smx ) {
        $Code =~ s|^(sub \s+ \w+) \s* \r?\n \{ |$1 {|smxg;
    }

    return $Code;
}

1;
