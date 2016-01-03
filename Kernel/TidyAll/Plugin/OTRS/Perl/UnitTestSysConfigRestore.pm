# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::UnitTestSysConfigRestore;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

our $ObjectManagerDisabled = 1;

# Make sure UTs which modify the SysConfig also restore it.

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my ( $ErrorMessage, $Counter );

    if ( $Code =~ m{->ConfigItemUpdate\(} ) {
        if ( $Code !~ m{RestoreSystemConfiguration\s*=>\s*1} ) {
            die __PACKAGE__ . "\n" . <<'EOF';
UnitTests which modify SysConfig entries also need to restore the SysConfig at the end. You can use the
HelperObject for this purpose:

        $Kernel::OM->ObjectParamAdd(
            'Kernel::System::UnitTest::Helper' => {
                RestoreSystemConfiguration => 1,
            },
        );
        my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

EOF
        }
    }

    return;
}

1;
