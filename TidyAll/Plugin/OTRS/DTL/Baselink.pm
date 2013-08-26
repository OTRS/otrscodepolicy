package TidyAll::Plugin::OTRS::DTL::Baselink;

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

        if ($Line =~ /<form.+action="\$Env{"Baselink"}"/i) {
            $ErrorMessage .= __PACKAGE__ . "\n" . <<EOF;
\$Env{\"Baselink\"} is not allowed in <form>tags. Use \$Env{\"CGIHandle\"}!
Line $Counter: $Line
EOF
        }
    }

    die $ErrorMessage if $ErrorMessage;
}

1;
