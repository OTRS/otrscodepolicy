package TidyAll::Plugin::OTRS::DTL::Select;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    my ($Counter, $ErrorMessage);

    for my $Line ( split /\n/, $Code ) {
        # look for forbidden selects that are not one-line, empty selects
        if ($Line =~ /<select/ && $Line !~ /<option/ && $Line !~ /<[\/]select/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ( $ErrorMessage ) {
        die __PACKAGE__ . "\n" . <<EOF;
Use Layout::BuildSelection instead of select elements in the DTL files.
$ErrorMessage
EOF
    }

    return;
}

1;
