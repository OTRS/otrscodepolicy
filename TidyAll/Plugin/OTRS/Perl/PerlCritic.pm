# --
# TidyAll/Plugin/OTRS/Perl/PerlCritic.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PerlCritic;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Perl);
use Perl::Critic;

our $Critic = Perl::Critic->new( -severity => 5 );

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    my @Violations = $Critic->critique($Filename);

    if (@Violations) {
        die __PACKAGE__ . "\n@Violations";
    }
}

1;
