#!/usr/bin/perl
# --
# bin/otrs.CodePolicy.pl - manually execute OTRSCodePolicy checks
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel';    # Find TidyAll
use lib dirname($RealBin) . '/Kernel/cpan-lib';

use Cwd;
use File::Basename;
use File::Spec;
use Getopt::Long;
use File::Find;
use Code::TidyAll;
use Code::TidyAll::Git::Util;

use TidyAll::OTRS;

my ( $Verbose, $Directory, $File, $Cached, $All, $Help );
GetOptions(
    'verbose'     => \$Verbose,
    'all'         => \$All,
    'cached'      => \$Cached,
    'directory=s' => \$Directory,
    'file=s'      => \$File,
    'help'        => \$Help,
);

if ($Help) {
    print <<EOF;
Usage: OTRSCodePolicy/bin/otrs.CodePolicy.pl [options]

    Performs OTRS code policy checks. Run this script from the toplevel directory
    of your module. By default it will only process files which are staged for
    git commit. Use --all or --directory to check all files or just one directory
    instead.

Options:
    -a, --all           Check all files recursively
    -d, --directory     Check only subdirectory
    -f, --file          Check only one file
    -c, --cached        Check only cached (staged files)
    -v, --verbose       Activate diagnostics
    -h, --help          Show this usage message
EOF
    exit 0;
}

my $ConfigurationFile = dirname($0) . '/../Kernel/TidyAll/tidyallrc';

# Change to otrs-code-policy directory to be able to load all plugins.
my $RootDir = getcwd();

my @Files;
if ( defined $Directory && length $Directory ) {

    my $Wanted = sub {

        # Skip non-regular files and directories.
        return if ( !-f $File::Find::name );

        # Also skip symbolic links, TidyAll does not like them.
        return if ( -l $File::Find::name );

        # Skip git and tidyall cache files
        return if index( $File::Find::name, '.git/' ) > -1;
        return if index( $File::Find::name, '.tidyall.d/' ) > -1;

        push @Files, $File::Find::name;
    };

    File::Find::find(
        $Wanted,
        File::Spec->catfile( $RootDir, $Directory ),
    );
}
elsif ( defined $File && length $File ) {
    @Files = ( File::Spec->catfile( $RootDir, $File ) );
}
elsif ( defined $Cached && length $Cached ) {
    my @StagedFiles = `git diff --name-only --cached`;
    for my $StagedFile (@StagedFiles) {
        chomp $StagedFile;
        push @Files, ( File::Spec->catfile( $RootDir, $StagedFile ) )
    }
}
elsif ( !$All ) {
    @Files = Code::TidyAll::Git::Util::git_uncommitted_files($RootDir);
}

# Ignore non-regular files and symlinks
@Files = grep { -f && !-l } @Files;

chdir dirname($0) . "/..";

my $TidyAll = TidyAll::OTRS->new_from_conf_file(
    $ConfigurationFile,
    no_cache   => 1,
    check_only => 0,
    mode       => 'cli',
    root_dir   => $RootDir,
    data_dir   => File::Spec->tmpdir(),
    verbose    => $Verbose ? 1 : 0,
);

$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

my @Results;
if ( !$All ) {
    @Results = $TidyAll->process_paths(@Files);
}
else {
    @Results = $TidyAll->process_all();
}

# Change working directory back.
chdir $RootDir;

my $FailMsg;
if ( my @ErrorResults = grep { $_->error() } @Results ) {
    my $ErrorCount = scalar(@ErrorResults);
    $FailMsg = sprintf(
        "%d file%s did not pass tidyall check\n",
        $ErrorCount, $ErrorCount > 1 ? "s" : ""
    );
}
die "$FailMsg\n" if $FailMsg;
