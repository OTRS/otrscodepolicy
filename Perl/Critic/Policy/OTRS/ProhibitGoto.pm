package Perl::Critic::Policy::OTRS::ProhibitGoto;

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use base 'Perl::Critic::Policy';

use Readonly;

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Use of "goto" is not allowed};
Readonly::Scalar my $EXPL => q{You should not use it at all in Perl code.};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word'  }

sub violates {
    my ( $self, $elem ) = @_;

    return if $elem ne 'goto';
    return $self->violation( $DESC, $EXPL, $elem );
}

1;
