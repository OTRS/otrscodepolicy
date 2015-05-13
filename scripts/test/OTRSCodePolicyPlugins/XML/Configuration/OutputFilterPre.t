# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'OutputFilterPre',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::OutputFilterPre)],
        Framework => '5.0',
        Source    => <<'EOF',
    <ConfigItem Name="Frontend::Output::FilterElementPre###OutputFilterPreOTRSAdjustSortTicketOverview" Required="1" Valid="1">
        <Description Translatable="1">This Outputfilter set the correct length for content of title column.</Description>
        <Group>OTRSAdjustSortTicketOverview</Group>
        <SubGroup>Frontend::Agent::TicketOverview</SubGroup>
        <Setting>
            <Hash>
                <Item Key="Module">Kernel::Output::HTML::OutputFilterPreOTRSAdjustSortTicketOverview</Item>
                <Item Key="Debug">0</Item>
                <Item Key="Templates">
                    <Hash>
                        <Item Key="AgentTicketOverviewSmall">1</Item>
                    </Hash>
                </Item>
            </Hash>
        </Setting>
    </ConfigItem>
EOF
        Exception => 1,
    },
    {
        Name      => 'OutputFilterPre, old framework',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::OutputFilterPre)],
        Framework => '4.0',
        Source    => <<'EOF',
    <ConfigItem Name="Frontend::Output::FilterElementPre###OutputFilterPreOTRSAdjustSortTicketOverview" Required="1" Valid="1">
        <Description Translatable="1">This Outputfilter set the correct length for content of title column.</Description>
        <Group>OTRSAdjustSortTicketOverview</Group>
        <SubGroup>Frontend::Agent::TicketOverview</SubGroup>
        <Setting>
            <Hash>
                <Item Key="Module">Kernel::Output::HTML::OutputFilterPreOTRSAdjustSortTicketOverview</Item>
                <Item Key="Debug">0</Item>
                <Item Key="Templates">
                    <Hash>
                        <Item Key="AgentTicketOverviewSmall">1</Item>
                    </Hash>
                </Item>
            </Hash>
        </Setting>
    </ConfigItem>
EOF
        Exception => 0,
    },
    {
        Name      => 'OputputFilterPost',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::OutputFilterPre)],
        Framework => '4.0',
        Source    => <<'EOF',
    <ConfigItem Name="Frontend::Output::FilterElementPost###OutputFilterPostOTRSAdjustSortTicketOverview" Required="1" Valid="1">
        <Description Translatable="1">This Outputfilter set the correct length for content of title column.</Description>
        <Group>OTRSAdjustSortTicketOverview</Group>
        <SubGroup>Frontend::Agent::TicketOverview</SubGroup>
        <Setting>
            <Hash>
                <Item Key="Module">Kernel::Output::HTML::OutputFilterPostOTRSAdjustSortTicketOverview</Item>
                <Item Key="Debug">0</Item>
                <Item Key="Templates">
                    <Hash>
                        <Item Key="AgentTicketOverviewSmall">1</Item>
                    </Hash>
                </Item>
            </Hash>
        </Setting>
    </ConfigItem>
EOF
        Exception => 0,
    },

);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
