package TidyAll::Plugin::OTRS::XML::XMLConfigSyntaxCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->is_disabled(Code => $Code);

    my $Error;
    my $Counter;

    for my $Line (split /\n/, $Code) {
        $Counter++;
        if ($Counter == 1) {
            if ($Counter == 1 && $Line !~ /^<\?xml.+\?>/ || $Line !~ /version="1.0"/ || $Line !~ /encoding="(?:iso-8859-1|utf-8)"/) {
                $Error .= "The first line of the file should have the content <?xml version=\"1.0\" encoding=\"utf-8\" ?>.\n";
            }
        }
        if ($Line =~ /^<otrs_config/) {
            if ($Line !~ /init="(Framework|Application|Config|Changes)"/ || $Line !~ /version="1.0"/) {
                $Error .= "The <otrs_config>-tag has missing or incorrect attributes. ExampleLine: <otrs_config version=\"1.0\" init=\"Application\"> YourLine: $Line.\n";
            }
        }
    }
    die $Error if $Error;
}

1;
