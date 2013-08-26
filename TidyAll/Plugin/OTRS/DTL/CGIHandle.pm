package TidyAll::Plugin::OTRS::DTL::CGIHandle;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    my $Counter;
    my $ErrorMessage;

    for my $Line ( split /\n/, $Code ) {
        $Counter ++;

        # allow IE workaround, e. g. <a href="$Env{"CGIHandle"}/$QData{"Filename"}?Action=...">xxx</a>
        if ($Line =~ /<a.+href="\$Env{"CGIHandle"}[^\/](.*)>/) {
            $ErrorMessage .= __PACKAGE__ . "\n" . <<EOF;
\$Env{\"CGIHandle\"} is not allowed in <a>tags. Use \$Env{\"Baselink\"}!
Line $Counter: $Line
EOF
        }
    }

    die $ErrorMessage if $ErrorMessage;
}

1;
