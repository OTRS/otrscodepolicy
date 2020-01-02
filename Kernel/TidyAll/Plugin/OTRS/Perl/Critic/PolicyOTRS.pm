# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::PolicyOTRS;

#
# Base class for custome Perl::Critic policies.
#

use strict;
use warnings;

no strict 'vars';    ## no critic

use vars qw(
    $TidyAll::OTRS::FrameworkVersionMajor
    $TidyAll::OTRS::FrameworkVersionMinor
);

# Base class for OTRS perl critic policies

sub IsFrameworkVersionLessThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::OTRS::FrameworkVersionMajor) {
        return 1 if $TidyAll::OTRS::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 0 if $TidyAll::OTRS::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 1 if $TidyAll::OTRS::FrameworkVersionMinor < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

1;
