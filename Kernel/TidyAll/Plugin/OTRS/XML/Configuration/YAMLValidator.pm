# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::YAMLValidator;

use strict;
use warnings;

# We use YAML::XS here because it is an external dependency of OTRS.
use YAML::XS();

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 8, 0 );

    $Code =~ s{
        (<Item[^>]+ValueType="YAML"[^>]*>\s*<!\[CDATA\[---\n)
        (.*?)
        (^\s*\]\]>\s*</Item>)}{
            eval {
                YAML::XS::Load($2);
            };
            if ($@) {
                die __PACKAGE__ . "\nCould not load YAML data for Item $1\nData:\n$2\nError: $@";
            }
        }exmsg;

    return;
}

1;
