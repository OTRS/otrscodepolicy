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
        Name      => 'Package without use Moose',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose)],
        Framework => '9.0',
        Source    => <<'EOF',
package Test;
1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Package with use Moose and no Moose',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose)],
        Framework => '9.0',
        Source    => <<'EOF',
package Test;
use Moose;

# code ...

no Moose;
1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Package with use Moose and without no Moose',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose)],
        Framework => '9.0',
        Source    => <<'EOF',
package Test;
use Moose;

# code ...

1;
EOF
        Result => <<'EOF',
package Test;
use Moose;

# code ...

no Moose;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Package with use Moose::Role and no Moose::Role',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose)],
        Framework => '9.0',
        Source    => <<'EOF',
package Test;
use Moose::Role;

# code ...

no Moose::Role;
1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Package with use Moose::Role and without no Moose::Role',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS9::UnimportMoose)],
        Framework => '9.0',
        Source    => <<'EOF',
package Test;
use Moose::Role;

# code ...

1;
EOF
        Result => <<'EOF',
package Test;
use Moose::Role;

# code ...

no Moose::Role;

1;
EOF
        Exception => 0,
    },

);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
