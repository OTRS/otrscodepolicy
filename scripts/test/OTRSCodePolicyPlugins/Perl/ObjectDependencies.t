# --
# OTRSCodePolicyPlugins/Perl/ObjectDependencies.t - code policy self tests
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers);

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'ObjectDependencies, no OM used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used (former default dependency)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Encode');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, default dependencies used with invalid short form in Get()',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Encode');
$Kernel::OM->Get('EncodeObject');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, dependency declared',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, dependency declared, invalid short form',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
for my $Needed (qw(TicketObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency in loop',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
for my $Needed (qw(Kernel::System::Ticket)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, Get called in for loop',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
for my $Needed (qw(Kernel::System::CustomObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::System::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
    'Kernel::System::User',
    'Kernel::System::Group',
    'Kernel::System::AuthSession',
    'Kernel::System::Web::Request',
);

$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( Kernel::System::User Kernel::System::Group )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, object manager disabled',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our $ObjectManagerDisabled = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, deprecated ObjectManagerAware flag',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
our $ObjectManagerAware = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
