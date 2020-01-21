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
        Name      => 'CacheNew, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::CacheNew)],
        Framework => '4.0',
        Source    => <<'EOF',
Kernel::System::Cache->new(%{$Self});
EOF
        Exception => 1,
    },
    {
        Name      => 'CacheNew, ok',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::CacheNew)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Cache');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
