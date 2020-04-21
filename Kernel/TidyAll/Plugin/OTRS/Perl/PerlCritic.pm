# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PerlCritic;

use strict;
use warnings;

use File::Basename;
use lib dirname(__FILE__) . '/../';    # Find our Perl::Critic policies

use parent qw(TidyAll::Plugin::OTRS::Perl);
use Perl::Critic;

use Perl::Critic::Policy::OTRS::ProhibitGoto;
use Perl::Critic::Policy::OTRS::ProhibitLowPrecendeceOps;
use Perl::Critic::Policy::OTRS::ProhibitSmartMatchOperator;
use Perl::Critic::Policy::OTRS::ProhibitRandInTests;
use Perl::Critic::Policy::OTRS::ProhibitOpen;
use Perl::Critic::Policy::OTRS::ProhibitUnless;
use Perl::Critic::Policy::OTRS::RequireCamelCase;
use Perl::Critic::Policy::OTRS::RequireLabels;
use Perl::Critic::Policy::OTRS::RequireParensWithMethods;
use Perl::Critic::Policy::OTRS::RequireTrueReturnValueForModules;

# Cache Perl::Critic object instance to save time. But cache it
#   for every framework version, because the configuration may differ.
our $CachedPerlCritic = {};

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my $FrameworkVersion = "$TidyAll::OTRS::FrameworkVersionMajor.$TidyAll::OTRS::FrameworkVersionMinor";

    if ( !$CachedPerlCritic->{$FrameworkVersion} ) {

        my $Severity = 4;    # STERN
        if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
            $Severity = 5;    #  GENTLE, less strict for older versions
        }
        my $Critic = Perl::Critic->new(
            -severity => $Severity,
            -exclude  => [
                'Modules::RequireExplicitPackage',    # this breaks in our scripts/test folder
            ],
        );
        $Critic->add_policy( -policy => 'OTRS::ProhibitGoto' );
        $Critic->add_policy( -policy => 'OTRS::ProhibitLowPrecendeceOps' );
        $Critic->add_policy( -policy => 'OTRS::ProhibitOpen' );
        $Critic->add_policy( -policy => 'OTRS::ProhibitRandInTests' );
        $Critic->add_policy( -policy => 'OTRS::ProhibitSmartMatchOperator' );
        $Critic->add_policy( -policy => 'OTRS::ProhibitUnless' );
        $Critic->add_policy( -policy => 'OTRS::RequireCamelCase' );
        $Critic->add_policy( -policy => 'OTRS::RequireLabels' );
        $Critic->add_policy( -policy => 'OTRS::RequireParensWithMethods' );
        $Critic->add_policy(
            -policy => 'OTRS::RequireTrueReturnValueForModules'
        );
        if ( !$Self->IsFrameworkVersionLessThan( 9, 0 ) ) {
            $Critic->add_policy( -policy => 'BuiltinFunctions::ProhibitStringySplit' );

            #$Critic->add_policy( -policy => 'ValuesAndExpressions::RequireQuotedHeredocTerminator' );
        }

        $CachedPerlCritic->{$FrameworkVersion} = $Critic;
    }

    # Force stringification of $Filename as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my @Violations = $CachedPerlCritic->{$FrameworkVersion}->critique("$Filename");

    if (@Violations) {
        return $Self->DieWithError("@Violations");
    }

    return;
}

1;
