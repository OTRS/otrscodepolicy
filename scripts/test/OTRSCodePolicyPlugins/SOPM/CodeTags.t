# --
# OTRSCodePolicyPlugins/SOPM/CodeTags.t - code policy self tests
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
        Name      => 'CodeTags, valid.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::CodeTags)],
        Framework => '4.0',
        Source    => <<'EOF',
    <CodeInstall Type="post"><![CDATA[
        $Kernel::OM->Get('var::packagesetup::MyPackge')->CodeInstall();
    ]]></CodeInstall>
EOF
        Exception => 0,
    },
    {
        Name      => 'CodeTags, old framework.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::CodeTags)],
        Framework => '3.3',
        Source    => <<'EOF',
    <CodeInstall Type="post">
        $Self->{LogObject}->Log(...)
    </CodeInstall>
EOF
        Exception => 0,
    },
    {
        Name      => 'CodeTags, $Self used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::CodeTags)],
        Framework => '4.0',
        Source    => <<'EOF',
    <CodeInstall Type="post"><![CDATA[
        $Self->{LogObject}->Log(...)
    ]]></CodeInstall>
EOF
        Exception => 1,
    },
    {
        Name      => 'CodeTags, no cdata.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::CodeTags)],
        Framework => '4.0',
        Source    => <<'EOF',
    <CodeInstall Type="post">
        $Kernel::OM->Get('var::packagesetup::MyPackge')->CodeInstall();
    </CodeInstall>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
