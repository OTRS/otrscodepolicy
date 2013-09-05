package TidyAll::Plugin::OTRS::SOPM::PackageRequired;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);
    return if ($Self->IsFrameworkVersionLessThan(3, 1));

    if ( $Code =~ m{<PackageRequired>}smx ) {
        die __PACKAGE__ . "\n" . <<EOF;
You use the attribute PackageRequired without a version tag.
Use: \"<PackageRequired Version="1.1.1">NewPackage</PackageRequired>
EOF
    }
}

1;
