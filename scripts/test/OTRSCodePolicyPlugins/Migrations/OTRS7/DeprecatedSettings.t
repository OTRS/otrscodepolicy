# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Test config setting definition for purposes of the unit testing.</Description>
        <Navigation>Core::Test</Navigation>
        <Value>
            <Hash>
                <Item Key="Key">Value</Item>
            </Hash>
        </Value>
EOF

my @Tests = (
    {
        Name      => 'Obsolete frontend setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Module###PublicFAQExplorer" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete frontend setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Module###PublicFAQExplorer" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete loader setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Customer::SelectedSkin" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete loader setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Customer::SelectedSkin" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete loader module setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete loader module setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete search router setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search::JavaScript###AgentCustomerInformationCenter" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete search router setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search::JavaScript###AgentCustomerInformationCenter" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
