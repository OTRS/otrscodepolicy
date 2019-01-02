# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::DTL::UniqueBlock;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my ( $Counter, $ErrorMessage, %BlockCounter );

    for my $Line ( split /\n/, $Code ) {
        if ( $Line =~ m{ ^ \s*? <!-- \s dtl:block: (\w+) \s* -->}xms ) {
            $BlockCounter{$1}++;
        }
    }

    for my $Block ( sort keys %BlockCounter ) {
        if ( $BlockCounter{$Block} == 1 ) {
            $ErrorMessage
                .= "Block usage error. You used the block '$Block' only one time, the closing block is missing.\n";
        }
        if ( $BlockCounter{$Block} > 2 ) {
            $ErrorMessage
                .= "A block name should be unique. But you use the block '$Block'  for more than one time.\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }

    return;
}

1;
