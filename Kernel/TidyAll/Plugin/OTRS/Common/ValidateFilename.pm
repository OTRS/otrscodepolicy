# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
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

    my @ForbiddenCharacters = (
        ' ', "\n", "\t", '"', '`', '´', '\'', '$', '!', '?,', '*',
        '(', ')', '{', '}', '[', ']', '#', '<', '>', ':', '\\', '|',
    );

    for my $ForbiddenCharacter (@ForbiddenCharacters) {
        if ( index( $Filename, $ForbiddenCharacter ) > -1 ) {
            my $ForbiddenList = join( ' ', @ForbiddenCharacters );
            die __PACKAGE__ . "\n" . <<EOF;
Forbidden character '$ForbiddenCharacter' found in file name.
You should not use these characters in file names: $ForbiddenList.
EOF
        }
    }

    return;
}

1;
