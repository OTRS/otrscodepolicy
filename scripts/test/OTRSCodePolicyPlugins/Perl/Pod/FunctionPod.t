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
        Name      => 'valid function documentation',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'heading that is not related to a function',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 How does singleton management work?

It creates objects as late as possible and keeps references to them. Upon destruction the objects
are destroyed in the correct order, based on their dependencies (see below).
EOF
        Exception => 0,
    },
    {
        Name      => 'function without parentheses',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'function with wrong name',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 WrongName()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'wrong function call used in example',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->WrongFunction('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'valid constructor with Create',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Creates a DateTime object. Do not use new() directly, instead use the object manager:


    # Create an object with current date and time
    # within time zone set in SysConfig OTRSTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'valid constructor with Get',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Don't use the constructor directly, use the ObjectManager instead:

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'valid constructor with new',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Fake for testing.

    my $TicketObject = Kernel::System::Ticket->new();

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
