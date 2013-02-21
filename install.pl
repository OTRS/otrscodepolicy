#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use FindBin qw($RealBin);

my $Directory = getcwd;

# install hook
symlink(
    File::Spec->catfile($RealBin, 'git','pre-commit'),
    File::Spec->catfile($Directory, '.git','hooks','pre-commit')
);

print "Installed hook in $Directory.\n\n";
