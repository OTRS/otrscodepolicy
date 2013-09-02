package TidyAll::Plugin::OTRS::Perl::LayoutObject;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    return if ($Self->IsFrameworkVersionLessThan(3, 3));

    # Check for presence of shebang line
    if ( $Code =~ m{LayoutObject}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use the LayoutObject in bin/ or in Kernel/System.
EOF
    }
    return;
}

1;
