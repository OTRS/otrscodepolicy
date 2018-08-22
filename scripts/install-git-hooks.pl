#!/usr/bin/perl
# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use Cwd;
use File::Spec;
use FindBin qw($RealBin);

my $Directory = getcwd;

# install hook
unlink File::Spec->catfile( $Directory, '.git', 'hooks', 'pre-commit' );
symlink(
    File::Spec->catfile( $RealBin, '..', 'Kernel', 'TidyAll', 'git-hooks', 'pre-commit.pl' ),
    File::Spec->catfile( $Directory, '.git', 'hooks', 'pre-commit' )
);
unlink File::Spec->catfile( $Directory, '.git', 'hooks', 'prepare-commit-msg' );
symlink(
    File::Spec->catfile(
        $RealBin, '..', 'Kernel', 'TidyAll', 'git-hooks', 'prepare-commit-msg.pl'
    ),
    File::Spec->catfile( $Directory, '.git', 'hooks', 'prepare-commit-msg' )
);

print "Installed git commit hooks in $Directory.\n\n";
