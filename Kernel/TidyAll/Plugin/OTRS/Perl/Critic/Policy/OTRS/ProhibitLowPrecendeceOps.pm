# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitLowPrecendeceOps;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.01';

my $Description = q{Use of low precedence operators is not allowed};
my $Explanation =
    q{Replace low precedence operators with the high precedence substitutes};

my %LowPrecendeceOperators = (
    not => '!',
    and => '&&',
    or  => '||',
);

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Operator' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if !grep { $Element eq $_ } keys %LowPrecendeceOperators;
    return $Self->violation( $Description, $Explanation, $Element );
}

1;
