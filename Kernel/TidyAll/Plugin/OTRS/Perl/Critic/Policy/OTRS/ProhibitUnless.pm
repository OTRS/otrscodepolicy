# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitUnless;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

our $VERSION = '0.01';

my $Description = q{Use of 'unless' is not allowed.};
my $Explanation = q{Please use a negating 'if' instead.};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    return 1;
}

sub violates {
    my ( $Self, $Element ) = @_;

    return if ( $Element->content() ne 'unless' );
    return $Self->violation( $Description, $Explanation, $Element );
}

1;
