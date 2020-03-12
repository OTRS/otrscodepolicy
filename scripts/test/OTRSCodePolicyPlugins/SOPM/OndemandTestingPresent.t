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
        Name      => 'Valid - Ondemand testing configuration present',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::OndemandTestingPresent)],
        Framework => '7.0',
        FileList  => [
            '.otrs-ci.yml',
        ],
        Source    => '',
        Exception => 0,
    },
    {
        Name      => 'Invalid - Ondemand testing configuration missing',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::OndemandTestingPresent)],
        Framework => '7.0',
        FileList  => [],
        Source    => '',
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
