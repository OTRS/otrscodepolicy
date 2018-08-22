# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::LintWithOurParsers;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Parser = XML::Parser->new();
    if ( !eval { $Parser->parse($Code) } ) {
        die __PACKAGE__ . "\nXML::Parser produced errors: $@\n";
    }

    # XML::Parser::Lite may not be installed, only check if present.
    if ( eval 'require XML::Parser::Lite' ) {    ## no critic
        my $ParserLite = XML::Parser::Lite->new();
        eval { $ParserLite->parse($Code) };
        if ($@) {
            die __PACKAGE__ . "\nXML::Parser::Lite produced errors: $@\n";
        }
    }
}

1;
