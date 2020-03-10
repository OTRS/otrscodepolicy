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
        Name      => 'There is overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<"EOF",
    <Setting Name="UnitTest::Blacklist###100-OTRSCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">SomeUnitTestBlacklist${RandomID}.t</Item>
                <Item ValueType="String">SomeDirectory/SomeUnitTestBlacklist${RandomID}.t</Item>
            </Array>
        </Value>
    </Setting>
EOF
        FileList => [
            "scripts/test/OTRSCodePolicySomeUnitTestBlacklist${RandomID}.t",
            "scripts/test/SomeDirectory/OTRSCodePolicySomeUnitTestBlacklist${RandomID}.t",
        ],
        Exception => 0,
    },
    {
        Name      => 'There is not overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<'EOF',
    <Setting Name="UnitTest::Blacklist###100-OTRSCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">SomeUnitTestBlacklistNonExistent.t</Item>
                <Item ValueType="String">SomeDirectory/SomeUnitTestBlacklistNonExistent.t</Item>
            </Array>
        </Value>
    </Setting>
EOF
        FileList  => [],
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
