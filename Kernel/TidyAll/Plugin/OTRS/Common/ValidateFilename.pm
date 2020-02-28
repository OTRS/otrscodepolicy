# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Common::ValidateFilename;

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin performs basic file name checks.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my @ForbiddenCharacters = (
        ' ', "\n", "\t", '"', '`', '´', '\'', '$', '!', '?,', '*',
        '(', ')', '{', '}', '[', ']', '#', '<', '>', ':', '\\', '|',
    );

    for my $ForbiddenCharacter (@ForbiddenCharacters) {
        if ( index( $Filename, $ForbiddenCharacter ) > -1 ) {
            my $ForbiddenList = join( ' ', @ForbiddenCharacters );
            return $Self->DieWithError(<<EOF);
Forbidden character '$ForbiddenCharacter' found in file name.
You should not use these characters in file names: $ForbiddenList.
EOF
        }
    }

    return;
}

1;
