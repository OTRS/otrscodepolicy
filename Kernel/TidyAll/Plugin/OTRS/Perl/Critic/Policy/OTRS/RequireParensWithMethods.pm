# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::RequireParensWithMethods;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.01';

my $Description = q{Method invocation should use "()"};
my $Explanation = q{Use "->MethodName()" instead of "->MethodName".};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Operator' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Element ne '->';

    my $Method = $Element->snext_sibling();

    # $Variable->();
    return if ref $Method eq 'PPI::Structure::List';

    # $Variable->method();
    return if ref $Method eq 'PPI::Structure::Subscript';

    my $List = $Method->snext_sibling();
    return if ref $List eq 'PPI::Structure::List';

    return $Self->violation( $Description, $Explanation, $Element );
}

1;
