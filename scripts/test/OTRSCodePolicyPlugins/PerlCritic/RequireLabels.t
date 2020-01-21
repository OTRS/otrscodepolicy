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
        Name      => 'next without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    next;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'next with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY;
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY;
}
EOF
    },
    {
        Name      => 'last without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    last;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'last with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    last KEY;
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    last KEY;
}
EOF
    },
    {
        Name      => 'next without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    next if (1);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'next with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY if (1);
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY if (1);
}
EOF
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
