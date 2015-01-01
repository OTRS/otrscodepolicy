# --
# OTRSCodePolicyPlugins/Common/HeaderlineFilename.t - code policy self tests
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
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
        Name      => 'HeaderlineFilename regular',
        Filename  => 'Type.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Common::HeaderlineFilename)],
        Framework => '3.3',
        Source    => <<'EOF',
# --
# Kernel/System/Type.pm - All ticket type related functions
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
EOF
        Exception => 0,
        Result    => <<'EOF',
# --
# Kernel/System/Type.pm - All ticket type related functions
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
EOF
    },
    {
        Name      => 'HeaderlineFilename wrong',
        Filename  => 'Type.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Common::HeaderlineFilename)],
        Framework => '3.3',
        Source    => <<'EOF',
# --
# Kernel/System/Type2.pm - All ticket type related functions
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
