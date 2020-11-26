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

## nofilter(TidyAll::Plugin::OTRS::Perl::Tests::Roles)
use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'ProvideTestPGPEnvironment missing',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Roles)],
        Framework => '8.0',
        Source    => <<'EOF',
with qw(
    Kernel::Test::Role::IsTestCase::Generic
    Kernel::Test::Role::Environment::RestoreDatabase
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');

    return 1;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ProvideTestPGPEnvironment present',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Roles)],
        Framework => '8.0',
        Source    => <<'EOF',
with qw(
    Kernel::Test::Role::IsTestCase::Generic
    Kernel::Test::Role::Environment::RestoreDatabase
    Kernel::Test::Role::Environment::ProvideTestPGPEnvironment
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');

    return 1;
}
EOF
        Exception => 0,
    },
    {
        Name      => 'ProvideTestSMIMEEnvironment missing',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Roles)],
        Framework => '8.0',
        Source    => <<'EOF',
with qw(
    Kernel::Test::Role::IsTestCase::Generic
    Kernel::Test::Role::Environment::RestoreDatabase
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');

    return 1;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ProvideTestSMIMEEnvironment present',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Tests::Roles)],
        Framework => '8.0',
        Source    => <<'EOF',
with qw(
    Kernel::Test::Role::IsTestCase::Generic
    Kernel::Test::Role::Environment::RestoreDatabase
    Kernel::Test::Role::Environment::ProvideTestSMIMEEnvironment
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');

    return 1;
}
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
