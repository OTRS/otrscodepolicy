# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::RequireParensWithMethods;

## no critic (Perl::Critic::Policy::OTRS::RequireCamelCase)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';

use Readonly;

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Method invocation should use "()"};
Readonly::Scalar my $EXPL => q{Use "->MethodName()" instead of "->MethodName".};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Operator' }

sub violates {
    my ( $self, $elem ) = @_;

    return if $elem ne '->';

    my $method = $elem->snext_sibling();

    # $Variable->();
    return if ref $method eq 'PPI::Structure::List';

    # $Variable->method();
    return if ref $method eq 'PPI::Structure::Subscript';

    my $list = $method->snext_sibling();
    return if ref $list eq 'PPI::Structure::List';

    return $self->violation( $DESC, $EXPL, $elem );
}

1;
