# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my $SmallName    = 'A';
my $MediumName   = 'A' x 100;
my $LongName     = 'A' x 200;
my $LimitName    = 'A' x 250;
my $OversizeName = 'A' x 251;
my $HugeName     = 'A' x 300;

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Disables the web installer (http://yourhost.example.com/otrs/installer.pl), to prevent the system from being hijacked. If set to "No", the system can be reinstalled and the current basic configuration will be used to pre-populate the questions within the installer script. If not active, it also disables the GenericAgent, PackageManager and SQL Box.</Description>
        <Group>Framework</Group>
        <SubGroup>Core</SubGroup>
        <Setting>
            <Option SelectedID="0">
                <Item Key="0" Translatable="1">No</Item>
                <Item Key="1" Translatable="1">Yes</Item>
            </Option>
        </Setting>
    </ConfigItem>
EOF

my @Tests = (
    {
        Name      => 'Small Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$SmallName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Medium Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$MediumName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Long Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$LongName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Limit Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$LimitName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'OverSize Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$OversizeName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 1,
    },
    {
        Name      => 'Huge Setting Name',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '6.0',
        Source    => <<"EOF",
    <ConfigItem Name="$HugeName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 1,
    },
    {
        Name      => 'Small Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$SmallName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Medium Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$MediumName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Long Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$LongName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'Limit Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$LimitName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 0,
    },
    {
        Name      => 'OverSize Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$OversizeName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 1,
    },
    {
        Name      => 'Huge Setting Name (Framework 5.0)',
        Filename  => 'Test.XML',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::XSDValidator)],
        Framework => '5.0',
        Source    => <<"EOF",
    <ConfigItem Name="$HugeName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
