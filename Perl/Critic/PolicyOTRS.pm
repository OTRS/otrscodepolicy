# --
# TidyAll/Plugin/OTRS/Perl/Critic/PolicyOTRS.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Perl::Critic::PolicyOTRS;

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
