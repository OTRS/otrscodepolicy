# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $RandomID = $Helper->GetRandomID();

my @Tests = (
    {
        Name      => 'YAML, no indentation',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
Key: Value
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
    {
        Name      => 'YAML, empty',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
    {
        Name      => 'YAML, with indentation',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
            Key: Value
            SubHash:
              SubKey: SubValue
            ]]></Item>
        </Value>
    </Setting>
EOF
        Result => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
Key: Value
SubHash:
  SubKey: SubValue
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
