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
## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS8::NewTestsNoLegacyCode)

my @Tests = (
    {
        Name      => 'Normal test case',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS8::NewTestsNoLegacyCode)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test::Case::Dummy;

use strict;
use warnings;

use Moose;
with qw(
    Kernel::Test::Role::IsTestCase
);
EOF
        Exception => 0,
    },
    {
        Name      => 'Test case trying to create legacy Helper object.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS8::NewTestsNoLegacyCode)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test::Case::Dummy;

use strict;
use warnings;

use Moose;
with qw(
    Kernel::Test::Role::IsTestCase
);

my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        Exception => 1,
    },

);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
