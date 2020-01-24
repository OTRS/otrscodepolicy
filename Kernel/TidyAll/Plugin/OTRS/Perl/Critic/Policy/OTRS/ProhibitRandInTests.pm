# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitRandInTests;

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

our $VERSION = '0.02';

my $Description = q{Use of "rand()" or "srand()" is not allowed in tests.};
my $Explanation = q{Use Kernel::System::UnitTest::Helper::GetRandomNumber() or GetRandomID() instead.};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

# Only apply to test (.t) files.
sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    return $Document->logical_filename() =~ m{ \.t \z }xms;
}

sub violates {
    my ( $Self, $Element ) = @_;

    if ( $Element eq 'rand' || $Element eq 'srand' ) {
        return $Self->violation( $Description, $Explanation, $Element );
    }

    return;
}

1;
