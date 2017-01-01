#!/usr/bin/perl
# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use IO::File;

=head1 SYNOPSIS

This hook inserts a custom prepared commit message into the git commit message.

=cut

my $OTRSCommitTemplateFile = '.git/OTRSCommitTemplate.msg';

if ( -r $OTRSCommitTemplateFile ) {

    # Get our content and prepend it
    my $FileHandle = IO::File->new( $OTRSCommitTemplateFile, 'r' );
    my @Content = $FileHandle->getlines();

    # Get the pre-populated file from GIT and keep its contents
    my $GitCommitTemplateFile = shift;
    $FileHandle = IO::File->new( $GitCommitTemplateFile, 'r' );
    push @Content, $FileHandle->getlines();

    # Write new commit message
    $FileHandle = IO::File->new( $GitCommitTemplateFile, 'w' );
    $FileHandle->print( join "", @Content );

    # Remove custom commit message template
    unlink $OTRSCommitTemplateFile;
}
