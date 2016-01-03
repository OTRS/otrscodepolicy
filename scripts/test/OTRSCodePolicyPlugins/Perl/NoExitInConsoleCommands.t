# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
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
        Name      => 'exit, forbidden',
        Filename  => 'Kernel/System/Console/Command/Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::NoExitInConsoleCommands)],
        Framework => '5.0',
        Source    => <<'EOF',
exit 1;
EOF
        Exception => 1,
    },
    {
        Name      => 'exit, forbidden',
        Filename  => 'Kernel/System/Console/Command/Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::NoExitInConsoleCommands)],
        Framework => '5.0',
        Source    => <<'EOF',
    if (1) { exit; };
EOF
        Exception => 1,
    },
    {
        Name      => '$Self->ExitCodeOk()',
        Filename  => 'Kernel/System/Console/Command/Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::NoExitInConsoleCommands)],
        Framework => '5.0',
        Source    => <<'EOF',
    return $Self->ExitCodeOk();
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
