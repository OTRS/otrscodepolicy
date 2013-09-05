package TidyAll::Plugin::OTRS::Perl::ParamObject;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    return if ($Self->IsFrameworkVersionLessThan(3, 3));

    if ( $Code =~ m{ParamObject}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use the ParamObject in bin/ or in Kernel/System.
EOF
    }
    return;
}

1;
