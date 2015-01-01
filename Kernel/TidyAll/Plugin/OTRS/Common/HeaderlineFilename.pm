# --
# TidyAll/Plugin/OTRS/Common/HeaderlineFilename.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::HeaderlineFilename;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin checks that the headerline has the correct file name (see
second line of this file as an example).

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $File = basename $File;
    my ( $Filename, $FileExtension ) = $File =~ /([\w_\-.]+\.(\w+?))$/;

    my @Lines = split /\n/, $Code;

    # ignore shebang line
    if ( $Lines[0] =~ m{\A\#!}smx ) {
        shift @Lines;
    }

    #die $Lines[1];

    if ( $Lines[1] !~ m{$Filename}smx ) {
        die __PACKAGE__ . "\n" . <<EOF;
The used filename is different of the filename in the headerline of the script!
File $Filename -> Line $Lines[1]
Don't forget to change the description at the right side of the headerline!
EOF
    }
    return;
}

1;
