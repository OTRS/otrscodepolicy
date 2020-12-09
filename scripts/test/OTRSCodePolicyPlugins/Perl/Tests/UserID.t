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

## nofilter(TidyAll::Plugin::OTRS::Perl::Tests::UserID)
use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'UserID replaced',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::UserID)],
        Framework => '8.0',
        Source    => <<'EOF',
$Self->BackendCall(
    UserID => 1,
    ChangeUserID => 1,
);

$Self->BackendCall(UserID => 1);
EOF
        Exception => 0,
        Result    => <<'EOF',
$Self->BackendCall(
    UserID => $Self->SystemUserID(),
    ChangeUserID => $Self->SystemUserID(),
);

$Self->BackendCall(UserID => $Self->SystemUserID());
EOF
    },
    {
        Name      => 'POD UserID not replaced',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::UserID)],
        Framework => '8.0',
        Source    => <<'EOF',
    $Self->BackendCall(
        UserID => 123,
        ChangeUserID => 123,
    );

    $Self->BackendCall(UserID => 123);
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
