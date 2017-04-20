# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::PermissionDataNotInSession;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::PermissionDataNotInSession)
## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
## nofilter(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{UserIsGroup}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Since OTRS 6, group permission information is no longer stored in the session nor the LayoutObject and cannot be fetched with 'UserIsGroup[]'. Instead, it can be fetched with PermissionCheck() on Kernel::System::Group or Kernel::System::CustomerGroup.

Example:

    my \$HasPermission = \$Kernel::OM->Get('Kernel::System::Group')->PermissionCheck(
        UserID    => \$UserID,
        GroupName => \$GroupName,
        Type      => 'move_into',
    );

$ErrorMessage
EOF
    }

    return;
}

1;
