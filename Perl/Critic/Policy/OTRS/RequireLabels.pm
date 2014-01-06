# --
# TidyAll/Plugin/OTRS/Perl/Critic/RequireLabels.pm - code quality plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Perl::Critic::Policy::OTRS::RequireLabels;

# nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use base 'Perl::Critic::Policy';
use base 'Perl::Critic::PolicyOTRS';

use Readonly;

Readonly::Scalar my $DESC => q{Please always use 'next' and 'last' with a label.};
Readonly::Scalar my $EXPL => q{};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Statement::Break' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 3, 5 );

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
