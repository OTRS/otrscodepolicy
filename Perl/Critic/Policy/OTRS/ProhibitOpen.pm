package Perl::Critic::Policy::OTRS::ProhibitOpen;

# nofilter(TidyAll::Plugin::OTRS::Common::HeaderlineFilename)
# nofilter(TidyAll::Plugin::OTRS::Legal::ReplaceCopyright)
# nofilter(TidyAll::Plugin::OTRS::Legal::AGPLValidator)
# nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use base 'Perl::Critic::Policy';

use Readonly;
use Scalar::Util qw();

our $VERSION = '0.01';

Readonly::Scalar my $DESC => q{Use of "open" is not allowed to read or write files.};
Readonly::Scalar my $EXPL => q{Use MainObject::FileRead() or FileWrite() instead.};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ( $Self, $Element ) = @_;

    # Only operate on calls of open()
    return if $Element ne 'open';

    my $NextSibling = $Element->snext_sibling();
    return if !$NextSibling;

    # Find open mode specifier
    my $OpenMode;

    # parentheses around open are present: open()
    if ( Scalar::Util::blessed($NextSibling) eq 'PPI::Structure::List' ) {
        my $Quote = $NextSibling->find('PPI::Token::Quote')->[0];
        return if ( !$Quote );
        $OpenMode = $Quote->string();
    }

    # parentheses are not present
    else {
        # Loop until we found the Token after the first comma
        my $Counter;
        while ( $Counter++ < 10 ) {
            $NextSibling = $NextSibling->snext_sibling();

            if (
                Scalar::Util::blessed($NextSibling) eq 'PPI::Token::Operator'
                && $NextSibling->content() eq ','
                )
            {
                my $Quote = $NextSibling->snext_sibling();
                return if ( !$Quote || !$Quote->isa('PPI::Token::Quote') );
                $OpenMode = $Quote->string();
                last;
            }
        }
    }

    if ( $OpenMode eq '>' || $OpenMode eq '<' ) {
        return $Self->violation( $DESC, $EXPL, $Element );
    }

    return;
}

1;
