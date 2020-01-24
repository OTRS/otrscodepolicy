# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::ProhibitOpen;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.01';

my $Description = q{Use of "open" is not allowed to read or write files.};
my $Explanation = q{Use MainObject::FileRead() or FileWrite() instead.};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
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
    if ( $NextSibling->isa('PPI::Structure::List') ) {
        my $Quote = $NextSibling->find('PPI::Token::Quote');
        return if ( ref $Quote ne 'ARRAY' );
        $OpenMode = $Quote->[0]->string();
    }

    # parentheses are not present
    else {
        # Loop until we found the Token after the first comma
        my $Counter;
        COUNTER:
        while ( $Counter++ < 10 ) {
            $NextSibling = $NextSibling->snext_sibling();

            if (
                $NextSibling->isa('PPI::Token::Operator')
                && $NextSibling->content() eq ','
                )
            {
                my $Quote = $NextSibling->snext_sibling();
                return if ( !$Quote || !$Quote->isa('PPI::Token::Quote') );
                $OpenMode = $Quote->string();
                last COUNTER;
            }
        }
    }

    if ( $OpenMode eq '>' || $OpenMode eq '<' ) {
        return $Self->violation( $Description, $Explanation, $Element );
    }

    return;
}

1;
