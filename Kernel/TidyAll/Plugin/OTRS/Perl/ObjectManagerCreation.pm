# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ObjectManagerCreation;
## nofilter(TidyAll::Plugin::OTRS::Perl::ObjectManagerCreation)

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    $Code = $Self->StripPod( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{ Kernel::System::ObjectManager->new }smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't create new instances of the ObjectManager in Perl modules. This should only be done in toplevel scripts.
$ErrorMessage
EOF
    }

    return;
}

1;
