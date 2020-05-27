#!/usr/bin/perl
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
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
use File::Path qw();
use Code::TidyAll;
use IPC::System::Simple qw(capturex);

use TidyAll::OTRS;

# Ensure UTF8 output works.
binmode( \*STDOUT, ':encoding(UTF-8)' );
binmode( \*STDERR, ':encoding(UTF-8)' );

my ( $Verbose, $Directory, $File, $Install, $Mode, $Cached, $All, $Help, $Processes );
GetOptions(
    'verbose'     => \$Verbose,
    'all'         => \$All,
    'cached'      => \$Cached,
    'directory=s' => \$Directory,
    'file=s'      => \$File,
    'install'     => \$Install,
    'mode=s'      => \$Mode,
    'help'        => \$Help,
    'processes=s' => \$Processes,
);

if ($Help) {
    print <<"EOF";
Usage: OTRSCodePolicy/bin/otrs.CodePolicy.pl [options]

    Performs OTRS code policy checks. Run this script from the toplevel directory
    of your module. By default it will only process files which are staged for
    git commit. Use --all or --directory to check all files or just one directory
    instead.

Options:
    -a, --all           Check all files recursively
    -d, --directory     Check only subdirectory
    -c, --cached        Check only cached (staged files in git directory)
    -f, --file          Check only one file
    -i, --install       Install additional required dependencies, such as ESLint and its plugins
    -m, --mode          Use custom Code::TidyAll mode (default: cli)
    -v, --verbose       Activate diagnostics
    -p, --processes     The number of processes to use (default: env var OTRSCODEPOLICY_PROCESSES if set, otherwise "6")
    -h, --help          Show this usage message
EOF
    exit 0;
}

my $BinDir = dirname($0);

if ($Install) {
    my $ESLintDir = $BinDir . '/../Kernel/TidyAll/Plugin/OTRS/JavaScript/ESLint';
    if ( !-d $ESLintDir ) {
        print "Error: Please run this command from the toplevel directory of your module.\n";
        exit 1;
    }

    my $RedirectOutput = $Verbose ? '' : '--silent > /dev/null';

    print "Performing `npm install --no-save` to make sure all needed node.js modules are present...\n";

    my $Success = system("cd $ESLintDir && npm install --no-save $RedirectOutput");

    if ( $Success != 0 ) {
        print "Error: Something went wrong during `npm install --no-save`.\n";
        exit 1;
    }

    print "Done.\n";
    exit 0;
}

my $ConfigurationFile = $BinDir . '/../Kernel/TidyAll/tidyallrc';

my $RootDir = getcwd();

my $TidyAll = TidyAll::OTRS->new_from_conf_file(
    $ConfigurationFile,
    check_only => 0,
    mode       => $Mode // 'cli',
    root_dir   => $RootDir,
    data_dir   => File::Spec->tmpdir(),
    verbose    => $Verbose ? 1 : 0,
);

$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

my @Files;

if ($All) {

    # Don't use TidyAll::process_all() or TidyAll::find_matched_files() as it is too slow on large code bases.
    @Files = @TidyAll::OTRS::FileList;
    @Files = $TidyAll->FilterMatchedFiles( Files => \@Files );
    @Files = map { File::Spec->catfile( $RootDir, $_ ) } @Files;
}
elsif ( defined $Directory && length $Directory ) {
    @Files = $TidyAll->FindFilesInDirectory( Directory => File::Spec->catfile( $RootDir, $Directory ) );
    @Files = $TidyAll->FilterMatchedFiles( Files => \@Files );
    @Files = map { File::Spec->catfile( $RootDir, $_ ) } @Files;
}
elsif ( defined $File && length $File ) {
    @Files = ( File::Spec->catfile( $RootDir, $File ) );
}
elsif ( defined $Cached && length $Cached ) {
    my @StagedFiles = `git diff --name-only --cached`;
    for my $StagedFile (@StagedFiles) {
        chomp $StagedFile;
        push @Files, ( File::Spec->catfile( $RootDir, $StagedFile ) );
    }
}
else {
    my $Output = capturex( 'git', "status", "--porcelain" );

    # Fetch all changed files, staged and unstaged
    my @ChangedFiles = grep { -f && !-l } ( $Output =~ /^\s*[MA]+\s+(.*)/gm );
    push @ChangedFiles, grep { -f && !-l } ( $Output =~ /^\s*RM?+\s+(.*?)\s+->\s+(.*)/gm );
    for my $ChangedFile (@ChangedFiles) {
        chomp $ChangedFile;
        push @Files, ( File::Spec->catfile( $RootDir, $ChangedFile ) );
    }

    # Always include all SOPM files to verify the file list.
    for my $SOPMFile ( map { File::Spec->abs2rel( $_, $RootDir ) } glob("$RootDir/*.sopm") ) {
        if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
            push @Files, ( File::Spec->catfile( $RootDir, $SOPMFile ) );
        }
    }
}

# Safeguard: ignore non-regular files and symlinks (causes TidyAll errors).
@Files = grep { -f && !-l } @Files;

my @GlobalResults = $TidyAll->ProcessPathsParallel(
    Processes => $Processes,
    FilePaths => \@Files,
);

$TidyAll->HandleResults(
    Results => \@GlobalResults
);
