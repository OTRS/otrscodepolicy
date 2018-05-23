# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::OndemandTestingPresent;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my $DocumentationPresent = grep { $_ =~ m{[.]otrs-ci[.]yml} } @TidyAll::OTRS::FileList;

    if ( !$DocumentationPresent ) {
        die __PACKAGE__ . "\nEvery package needs to contain an active OnDemand testing configuration (.otrs-ci.yml).\n";
    }
}

1;
