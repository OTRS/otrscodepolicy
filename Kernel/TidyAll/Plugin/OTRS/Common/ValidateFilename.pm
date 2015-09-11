# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::ValidateFilename;

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin performs basic file name checks.

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    if ( $Filename =~ m{[ ]} ) {
        die __PACKAGE__ . "\n" . <<EOF;
Dont't use spaces in file names.
EOF
    }

    return;
}

1;
