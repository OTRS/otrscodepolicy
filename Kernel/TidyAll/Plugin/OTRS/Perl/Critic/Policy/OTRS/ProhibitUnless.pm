package Perl::Critic::Policy::OTRS::ProhibitUnless;

# nofilter(TidyAll::Plugin::OTRS::Common::HeaderlineFilename)
# nofilter(TidyAll::Plugin::OTRS::Legal::ReplaceCopyright)
# nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
# nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

use Readonly;

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Use of 'unless' is not allowed.};
Readonly::Scalar my $EXPL => q{Please use a negating 'if' instead.};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    return if ( $Element->content() ne 'unless' );
    return $Self->violation( $DESC, $EXPL, $Element );
}

1;
