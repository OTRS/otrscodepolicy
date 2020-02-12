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

my @Tests = (
    {
        Name      => 'ESLint (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::ESLint)],
        Framework => '8.0',
        Source    => <<'EOF',
"use strict;"
EOF
        Exception => 0,
    },
    {
        Name      => 'ESLint (syntax error)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::ESLint)],
        Framework => '8.0',
        Source    => <<'EOF',
some syntax error
EOF
        Exception => 1,
    },

);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
