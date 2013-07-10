package TidyAll::Plugin::OTRS::XMLCheckWithOurParsers;

use strict;
use warnings;

BEGIN {
  $TidyAll::Plugin::OTRS::XMLCheckWithOurParsers::VERSION = '0.1';
}
use base qw(Code::TidyAll::Plugin);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

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
