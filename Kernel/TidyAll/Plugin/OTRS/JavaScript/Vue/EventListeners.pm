# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 DESCRIPTION

SPAs are very sensitive about memory leaks caused by improperly cleaned up event handlers.

This filter performs a rudimentary check for this: make sure that event handlers are cleaned up,
and do not contain anonymous functions.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my $ErrorMessage;

    my %EventBalance;

    # We need a sub to be able to perform an early return in the regex eval block.
    my $CheckEvents = sub {

        # print "Listener found: $1 $2 $3 $4\n";
        my $TargetObject     = $+{TargetObject};
        my $RegistrationType = $+{RegistrationType};
        my $EventName        = $+{EventName};
        my $EventHandler     = $+{EventHandler};

        # Special handling for DOM event listeners.
        if ( $RegistrationType eq 'addEventListener' || $RegistrationType eq 'removeEventListener' ) {

            # Event white list.
            if ( $EventName eq 'beforeunload' ) {
                return;
            }
            if ( $TargetObject !~ m{(^|[.])(window|document)}smxg ) {
                return;
            }
        }

        # Special handling for Vue event listeners.
        if ( $RegistrationType eq '$on' || $RegistrationType eq '$off' ) {

            # Ignore events of the Vue application itself.
            if ( substr( $TargetObject, 0, 3 ) eq 'vm.' ) {
                return;
            }
        }

        if ( $RegistrationType eq '$off' || $RegistrationType eq 'removeEventListener' ) {
            $EventBalance{$TargetObject}->{$EventName}--;
        }
        else {
            $EventBalance{$TargetObject}->{$EventName}++;
        }

        if ( $EventHandler =~ m{function | =>} ) {
            $ErrorMessage
                .= "The event listener for '$EventName' on '$TargetObject' may not contain an anonymous function (found: '$EventHandler').\n";
        }

        return;
    };

    # Find all event listener registrations in the code.
    $Code =~ s{
        (?:^|\s)
        (?<TargetObject>[a-zA-Z0-9_\$.]+)
        [.]
        (?<RegistrationType>\$on|\$off|addEventListener|removeEventListener)
        [(]
        ['"](?<EventName>[^'"]+)['"]
        \s*,\s*
        (?<EventHandler>.*?)
        $
    }{
        $CheckEvents->();
        '';
    }esmxg;

    for my $TargetObject ( sort keys %EventBalance ) {
        for my $EventName ( sort keys %{ $EventBalance{$TargetObject} // {} } ) {
            if ( $EventBalance{$TargetObject}->{$EventName} > 0 ) {
                $ErrorMessage
                    .= "The event listener for '$EventName' was not as often added as removed from '$TargetObject'.\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
