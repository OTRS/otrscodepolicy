# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::RequireLabels;

## nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

use Readonly;

Readonly::Scalar my $DESC => q{Please always use 'next' and 'last' with a label.};
Readonly::Scalar my $EXPL => q{};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Statement::Break' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    my @Children = $Element->children();
    if ( $Children[0]->content() ne 'next' && $Children[0]->content() ne 'last' ) {
        return;
    }

    my $Label = $Children[0]->snext_sibling();

    if (
        !$Label
        || !$Label->isa('PPI::Token::Word')
        || $Label->content() !~ m{^[A-Z_]+}xms
        )
    {
        return $Self->violation( $DESC, $EXPL, $Element );
    }

    return;
}

1;
