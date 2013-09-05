package TidyAll::Plugin::OTRS::SOPM::FileRights;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    my ($ErrorMessage, $Counter);

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line !~ m/<File.*\/>/;
        if ($Line =~ m/<File.*Location="([^"]+)".*\/>/) {
            if ($1 && $1 =~ /^(pl|sh|fpl|psgi|sh)$/) {
                if ($Line !~ /Permission="[750]{3}"/) {
                    $ErrorMessage .= "Line $Counter: $Line";
                }
            }

            else {
                if ($Line !~ /Permission="[640]{3}"/) {
                    $ErrorMessage .= "Line $Counter: $Line";
                }
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
A <File>-Tag has wrong permissions. Script files normally need 755 rights, the others 644.
$ErrorMessage
EOF
    }

    return;
}

1;
