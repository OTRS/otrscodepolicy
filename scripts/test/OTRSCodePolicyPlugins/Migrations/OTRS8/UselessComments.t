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
## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS8::UselessComments)

my @Tests = (
    {
        Name      => 'Normal comments',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS8::UselessComments)],
        Framework => '8.0',
        Source    => <<'EOF',
# Some useful comment.

# A multiline comment explaining
#   some stuff in a detailed way.
EOF
        Exception => 0,
    },
    {
        Name      => 'Stupid comments',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Migrations::OTRS8::UselessComments)],
        Framework => '8.0',
        Source    => <<'EOF',
some code here

# get needed objects
# Get needed objects.
# get needed variables
# Get needed variables
# get selenium object
# Get Config object.
# get script alias
# get valid list
# allocate new hash for object
# check needed stuff
# check needed data
# check needed params.
# check needed objects.
more code here
EOF
        Result => <<'EOF',
some code here

more code here
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
