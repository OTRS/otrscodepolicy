# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitRandInTests;

## no critic (Perl::Critic::Policy::OTRS::RequireCamelCase)

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

use Readonly;

our $VERSION = '0.02';

Readonly::Scalar my $DESC => q{Use of "rand()" or "srand()" is not allowed in tests.};
Readonly::Scalar my $EXPL => q{Use Kernel::System::UnitTest::Helper::GetRandomNumber() or GetRandomID() instead.};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    return if !$Self->_is_test($Element);

    if ( $Element eq 'rand' || $Element eq 'srand' ) {
        return $Self->violation( $DESC, $EXPL, $Element );
    }

    return;
}

sub _is_test {
    my ( $Self, $Element ) = @_;

    my $Document = $Element->document();
    my $Filename = $Document->logical_filename();
    my $IsTest   = $Filename =~ m{ \.t \z }xms;

    return $IsTest;
}

1;
