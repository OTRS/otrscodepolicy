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

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
no warnings 'redefine';    ## no critic
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'PerlCritic ProhibitStringySplit with string, allowed for OTRS 8',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split ':', 'some::code';
EOF
        Exception => 0,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with string',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split ':', 'some::code';
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with regexes',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split /:/, 'some::code';
@Strings = split m/:/, 'some::code';
@Strings = split(m/:/, 'some::code');
@Strings = split((m/:/, 'some::code'));
@Strings = split qr{:}, 'some::code';
EOF
        Exception => 0,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with regex variable',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $Regex = qr{:};
my @Strings = split $Regex, 'some::code';
@Strings = split($Regex, 'some::code');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
