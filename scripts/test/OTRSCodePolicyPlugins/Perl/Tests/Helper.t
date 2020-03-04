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

## nofilter(TidyAll::Plugin::OTRS::Perl::Tests::Helper)
use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Helper not used',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper used',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper created before Selenium object',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper created after Selenium object',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        Exception => 1,
    },
    {
        Name      => 'RestoreDatabase in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
        Exception => 1,
    },
    {
        Name      => 'Set ProvideTestPGPEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestPGPEnvironment => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing ProvideTestPGPEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');
EOF
        Exception => 1,
    },
    {
        Name      => 'Set ProvideTestSMIMEEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestSMIMEEnvironment => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing ProvideTestSMIMEEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
