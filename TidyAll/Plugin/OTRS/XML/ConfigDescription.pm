package TidyAll::Plugin::OTRS::XML::ConfigDescription;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    my ($ErrorMessage, $Counter, $NavBar);

    for my $Line (split /\n/, $Code) {
        $Counter++;
        if ($Line =~ /<NavBar/) {
            $NavBar = 1;
        }
        if ($Line =~ /<\/NavBar/) {
            $NavBar = 0;
        }

        if (!$NavBar && $Line =~ /<Description.+?>(.).*?(.)<\/Description>/) {
            if ($2 ne '.' && $2 ne '?' && $2 ne '!') {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            elsif ($1 !~ /[A-ZËÜÖ"]/) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . <<EOF;
Please make complete sentences in <Description> tags: start with a capital letter and finish with a dot.
$ErrorMessage
EOF
    }
}

1;
