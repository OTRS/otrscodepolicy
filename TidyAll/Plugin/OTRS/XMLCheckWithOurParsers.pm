package TidyAll::Plugin::OTRS::XMLCheckWithOurParsers;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::PluginBase);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->is_disabled(Code => $Code);

    my $Parser = XML::Parser->new();
    if ( !eval { $Parser->parse( $Code ) } ) {
        die "ERROR: XMLCheckWithOurParsers() - XML::Parser produced errors!\n";
    }

    # XML::Parser::Lite may not be installed, only check if present.
    if ( eval 'require XML::Parser::Lite' ) { ## no critic
        my $ParserLite =  XML::Parser::Lite->new();
        eval { $ParserLite->parse( $Code ) };
        if ( $@ ) {
            die "ERROR: XMLCheckWithOurParsers() - XML::Parser::Lite produced errors!\n";
        }
    }
}

1;
