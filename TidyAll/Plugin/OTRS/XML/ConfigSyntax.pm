package TidyAll::Plugin::OTRS::XML::ConfigSyntax;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    my $ErrorMessage;
    my $Counter;

    for my $Line (split /\n/, $Code) {
        $Counter++;
        # Check first XML line
        if ( $Counter == 1 ) {
            if (
                $Line !~ /^<\?xml.+\?>/
                || $Line !~ /version=["'']1.[01]["']/
                || $Line !~ /encoding=["'](?:iso-8859-1|utf-8)["']/i)
            {
                $ErrorMessage .= "The first line of the file should have the content <?xml version=\"1.0\" encoding=\"utf-8\" ?>.\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }

        # Validate otrs_config tag
        if ($Line =~ /^<otrs_config/) {
            if ($Line !~ /init="(Framework|Application|Config|Changes)"/ || $Line !~ /version="1.0"/) {
                $ErrorMessage .= "The <otrs_config>-tag has missing or incorrect attributes. ExampleLine: <otrs_config version=\"1.0\" init=\"Application\">\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
