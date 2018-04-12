package Perl::Critic::Policy::OTRS::RequireCamelCase;

# nofilter(TidyAll::Plugin::OTRS::Common::HeaderlineFilename)
# nofilter(TidyAll::Plugin::OTRS::Legal::ReplaceCopyright)
# nofilter(TidyAll::Plugin::OTRS::Legal::AGPLValidator)
# nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTRS';

use Readonly;

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Variable, subroutine, and package names have to be in CamelCase};
Readonly::Scalar my $EXPL => q{};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }

my %dispatcher = (
    'PPI::Statement::Sub'     => \&IsCamelCase,
    'PPI::Statement::Package' => \&IsCamelCase,
    'PPI::Token::Symbol'      => \&VariableIsCamelCase,
);

sub applies_to {
    keys %dispatcher,;
}

sub violates {
    my ( $Self, $Element ) = @_;

    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    $Self->{Errors} = ();

    my $Function = $dispatcher{ ref $Element };
    return if !$Function;
    return if $Self->$Function($Element);

    return $Self->violation( "$DESC: " . join( ", ", @{ $Self->{Errors} } ), $EXPL, $Element );
}

sub IsCamelCase {
    my ( $Self, $Element ) = @_;

    my $Name = $Element->find('PPI::Token::Word')->[1];

    return 1 if !$Name;

    my %AllowedFunctions = (
        new => 1,
    );

    if ( $Element->isa('PPI::Statement::Sub') && $AllowedFunctions{$Name} ) {
        return 1;
    }
    elsif ( $Element->isa('PPI::Statement::Package') ) {
        if (
            $Name =~ m{ Kernel::Language :: [a-z]{2,3}_ }xms
            || $Name eq 'main'
            || $Name =~ m{ ^var::packagesetup:: }xms
            )
        {
            return 1;
        }
    }

    my $IsCamelCase = !( $Name !~ m{ \A _* [A-Z][a-z]* }xms || $Name =~ m{ [^_]_ }xms );

    if ( !$IsCamelCase ) {
        push @{ $Self->{Errors} }, $Name;
    }

    return $IsCamelCase;
}

sub VariableIsCamelCase {
    my ( $Self, $Element ) = @_;

    my $Name = "$Element";
    return 1 if !$Name;

    # Allow Perl builtins.
    return 1 if $Name eq '$a';
    return 1 if $Name eq '$b';

    # Ignore function calls
    return 1 if substr( $Name, 0, 1 ) eq '&';

    # Allow short variable names with lowercase characters like $s.
    return 1 if length $Name == 2;

    my $IsCamelCase = !( $Name !~ m{ \A [\*\@\$\%]_*[A-Z][a-z]* }xms || $Name =~ m{ [^_]_ }xms );

    if ( !$IsCamelCase ) {
        push @{ $Self->{Errors} }, $Name;
    }

    return $IsCamelCase;
}

1;
