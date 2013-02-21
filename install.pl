#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use FindBin qw($RealBin);

my $Directory = getcwd;

# install hook
unlink File::Spec->catfile($Directory, '.git','hooks','pre-commit');
symlink(
    File::Spec->catfile($RealBin, 'TidyAll', 'git-hooks','pre-commit'),
    File::Spec->catfile($Directory, '.git','hooks','pre-commit')
);

print "Installed hook in $Directory.\n\n";
