#!/usr/bin/perl
# --
# TidyAll/git-hooks/prepare-commit-msg.pl - git hook
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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
