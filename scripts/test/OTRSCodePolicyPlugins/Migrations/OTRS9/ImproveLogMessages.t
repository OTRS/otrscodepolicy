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
## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)

my @Tests = (
    {
        Name      => '"Need ..."',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if (!$Param{$_}) {
        $LogObject->Log(
            Priority => "error",
            Message  => "Need $_.",
        );
    }
EOF
        Result => <<'EOF',
    if (!$Param{$_}) {
        $LogObject->Error(
            "The required parameter '$_' is missing.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with different order and quotes',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if (!defined $Param{ACLID}) {

        $LogObject->Log(
            Message => 'Need ACLID!!!',
            Priority => 'error',
        );
    }
EOF
        Result => <<'EOF',
    if (!defined $Param{ACLID}) {

        $LogObject->Error(
            "The required parameter 'ACLID' is missing.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with defined',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !defined( $Param{$_} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Message => 'Need ACLID in Data!',
            Priority => 'error',
        );
    }
EOF
        Result => <<'EOF',
    if ( !defined( $Param{$_} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The required parameter 'ACLID' is missing.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with param',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !$Param{$Argument} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Message => 'Need ACLID!!!',
            Priority => 'error',
        );
    }
EOF
        Result => <<'EOF',
    if ( !$Param{$Argument} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The required parameter 'ACLID' is missing.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with variable',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !$ID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need UserLogin!",
        );
    }
EOF
        Result => <<'EOF',
    if ( !$ID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The required parameter 'UserLogin' is missing.",
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with non-boolean check',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !is_HashRefWithData( $Param{DebuggerConfig} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need DebuggerConfig!',
        );
    }
EOF
        Result => <<'EOF',
    if ( !is_HashRefWithData( $Param{DebuggerConfig} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The parameter 'DebuggerConfig' is invalid.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with complex check and opening brace on new line',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( $Param{CategoryFiles} && !$Param{Category} )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Category",
        );
    }
EOF
        Result => <<'EOF',
    if ( $Param{CategoryFiles} && !$Param{Category} )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The parameter 'Category' is invalid.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Need ..." with "or" statement',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !$Param{XML} && !$Param{XMLFile} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need XML or XMLFile!',
        );
    }
EOF
        Result => <<'EOF',
    if ( !$Param{XML} && !$Param{XMLFile} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "One of the parameters 'XML' or 'XMLFile' is required, but none was provided.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"Got no ..."',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !$Param{$Needed} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Got no $Needed!!',
        );
    }
EOF
        Result => <<'EOF',
    if ( !$Param{$Needed} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The required parameter '$Needed' is missing.",
            Context => \%Param,
        );
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"... is invalid"',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !is_HashRefWithData( $Param{Body} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Body is invalid!",
        );
        return;
    }
EOF
        Result => <<'EOF',
    if ( !is_HashRefWithData( $Param{Body} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The parameter 'Body' is invalid.",
            Context => \%Param,
        );
        return;
    }
EOF
        Exception => 0,
    },
    {
        Name      => '"... is missing or invalid"',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages)],
        Framework => '9.0',
        Source    => <<'EOF',
    if ( !is_StrWithData( $Param{DocumentType} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "DocumentType is missing or invalid!",
        );
        return;
    }
EOF
        Result => <<'EOF',
    if ( !is_StrWithData( $Param{DocumentType} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Error(
            "The parameter 'DocumentType' is invalid.",
            Context => \%Param,
        );
        return;
    }
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
