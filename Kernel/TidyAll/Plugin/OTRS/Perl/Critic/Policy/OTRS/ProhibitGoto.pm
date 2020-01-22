# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitGoto;

## no critic (Perl::Critic::Policy::OTRS::RequireCamelCase)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';

use Readonly;
use Scalar::Util qw();

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Don't use "goto" in Perl code.};
Readonly::Scalar my $EXPL => q{};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Element ne 'goto';
    return $Self->violation( $DESC, $EXPL, $Element );
}

1;
