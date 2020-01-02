# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::SortKeys;

use strict;
use warnings;

## nofilter(TidyAll::Plugin::OTRS::Perl::SortKeys)

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

=head1 SYNOPSIS

This module inserts a sort statements to lines like

    for my $Module (sort keys %Modules) ...

because the keys randomness can be a source of problems
that is hard to debug.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    $Code =~ s{ ^ (\s* for \s+ my \s+ \$ \w+ \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;
    $Code =~ s{ ^ (\s* for \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;

    return $Code;
}

sub validate_source {     ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{ (?: sort)?[ ]keys \s+ [\$|\\] }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Dont use hash references while accesing its keys
$ErrorMessage
EOF
    }

    return;
}

1;
