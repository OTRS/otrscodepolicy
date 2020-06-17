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
        Name      => 'All fine',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
use strict;
use warnings;

sub MyFunction {}
my $CamelCaseVar = 1;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Wrong sub',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
use strict;
use warnings;

sub my_function {}

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'Wrong var',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
use strict;
use warnings;

my $_wrong_variable = 1;

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'All fine',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

sub MyFunction {}
my $CamelCaseVar = 1;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Wrong sub',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

sub my_function {}

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'Wrong var',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

my $_wrong_variable = 1;

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'Package Variable',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

my $OTHER::PACKAGE::_private_variable = 1;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (use parent)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use parent qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (use base)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use base qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (Moose + extend)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moose;
extends qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (Moose::Role + with)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moose::Role;
with qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (Moo::Role + with)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moo::Role;
with qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (Moo + extends)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moo;
extends qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Derived Package (Moose + extends)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moose;
extends qw(My::Package);

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Moose Package, but not derived',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Moose;
use Moose::Role;

sub my_function {}

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'RequireBaseClass',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

$Kernel::OM->Get('Kernel::System::Main')->RequireBaseClass('Some::Class');

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Mojo::Base',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use Mojo::Base 'Some::Class';

sub overridden_method {}

1;
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
