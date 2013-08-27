package TidyAll::Plugin::OTRS::Common::CustomizationMarkers;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    my ($Counter, $Flag, $ErrorMessage);

    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ($Line =~ /^[^#]/ && $Counter < 24) {
            $Flag = 1;
        }
        if ($Line =~ /^ *# --$/ && ($Counter > 23 || ($Counter > 10 && $Flag))) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ($Line =~ /^ *# -$/) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ($Line =~ /^ *##+ -+$/) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ($Line =~ /^ *#+ *[\*\+]+$/) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ($Line =~ /^ *##+/) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }
    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Please remove or replace wrong Separators like '# --', valid only: # --- (for customizing otrs files).
$ErrorMessage
EOF
    }
    return;
}

1;
