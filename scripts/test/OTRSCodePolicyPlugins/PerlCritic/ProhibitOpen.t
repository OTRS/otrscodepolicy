# --
# OTRSCodePolicyPlugins/PerlCritic/ProhibitOpen.t - code policy self tests
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
        Name      => 'PerlCritic ProhibitOpen regular file, old-style read',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<filename.txt');
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, read',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<', 'filename.txt');
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, read, no parentheses, bareword filehandle',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
open FH, '<', 'filename.txt';
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, write',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '>', 'filename.txt');
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, write, no parentheses',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, '>', 'filename.txt';
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, bidirectional',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, external command',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, unclear mode',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen in another context',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
