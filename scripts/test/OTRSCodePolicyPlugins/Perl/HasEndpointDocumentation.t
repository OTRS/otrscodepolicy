# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTRS::Perl::TestSubs)

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'HasEndpointDocumentation, no endpoints used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::HasEndpointDocumentation)],
        Framework => '4.0',
        Source    => <<'EOF',
package Kernel::WebApp::Controller::API::Agent::UserActivity::Registration;

use strict;
use warnings;

use Moose;

sub Description { return 'Test description'; }

sub ExampleResponses {
    return {
        200 => {
            Description => 'Endpoint worked correctly.',
            Example     => {},
        },

        900 => {
            Description => 'Something went wrong.',
            Example     => {
                ErrorIdentifier => 'SomethingFailed',
                ErrorMessage    => 'Some errors occured.',
            },
        },
    };
}

no Moose;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'HasEndpointDocumentation, no documentation subroutines used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::HasEndpointDocumentation)],
        Framework => '7.0',
        Source    => <<'EOF',
package Kernel::WebApp::Controller::API::Agent::UserActivity::Registration;

use strict;
use warnings;

use Moose;

sub Test { return; }

no Moose;

1;
EOF
        Exception => 0,
    },
    {
        Name      => 'HasEndpointDocumentation, documentation subroutines but no role defined.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::HasEndpointDocumentation)],
        Framework => '7.0',
        Source    => <<'EOF',
package Kernel::WebApp::Controller::API::Agent::UserActivity::Registration;

use strict;
use warnings;

use Moose;

sub Description { return 'Test description'; }

sub ExampleResponses {
    return {
        200 => {
            Description => 'Endpoint worked correctly.',
            Example     => {},
        },

        900 => {
            Description => 'Something went wrong.',
            Example     => {
                ErrorIdentifier => 'SomethingFailed',
                ErrorMessage    => 'Some errors occured.',
            },
        },
    };
}

no Moose;

1;
EOF
        Exception => 1,
    },
    {
        Name      => 'HasEndpointDocumentation, documentation subroutines and role defined.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::HasEndpointDocumentation)],
        Framework => '7.0',
        Source    => <<'EOF',
package Kernel::WebApp::Controller::API::Agent::UserActivity::Registration;

use strict;
use warnings;

use Moose;

with 'Kernel::WebApp::Controller::API::Role::HasEndpointDocumentation';

sub Description { return 'Test description'; }

sub ExampleResponses {
    return {
        200 => {
            Description => 'Endpoint worked correctly.',
            Example     => {},
        },

        900 => {
            Description => 'Something went wrong.',
            Example     => {
                ErrorIdentifier => 'SomethingFailed',
                ErrorMessage    => 'Some errors occured.',
            },
        },
    };
}

no Moose;

1;
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
