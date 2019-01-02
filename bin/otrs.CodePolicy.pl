#!/usr/bin/perl
# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
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

use POSIX ":sys_wait_h";
use Time::HiRes qw(sleep);

use TidyAll::OTRS;

my ( $Verbose, $Directory, $File, $Mode, $Cached, $All, $Help, $Processes );
GetOptions(
    'verbose'     => \$Verbose,
    'all'         => \$All,
    'cached'      => \$Cached,
    'directory=s' => \$Directory,
    'file=s'      => \$File,
    'mode=s'      => \$Mode,
    'help'        => \$Help,
    'processes=s' => \$Processes,
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
    -c, --cached        Check only cached (staged files in git directory)
    -f, --file          Check only one file
    -m, --mode          Use custom Code::TidyAll mode (default: cli)
    -v, --verbose       Activate diagnostics
    -p, --processes     The number of processes to use (default 6)
    -h, --help          Show this usage message
EOF
    exit 0;
}

my $ConfigurationFile = dirname($0) . '/../Kernel/TidyAll/tidyallrc';

my $RootDir = getcwd();

if ( !defined $Processes ) {
    $Processes = 6;
}

# To store results from child processes.
my $TempDirectory = dirname($0) . '/../var/tmp/OTRSCodePolicy/';

if ( !-e $TempDirectory ) {

    File::Path::mkpath( $TempDirectory, 0, 0770 );    ## no critic

    if ( !-e $TempDirectory ) {
        print "\nCan't create directory '$TempDirectory': $!\n";
        exit 1;
    }
}

# Make sure to cleanup log directory.
unlink glob "'$TempDirectory/*.tmp'";

my @TempFiles = glob "$TempDirectory/*.tmp";
if (@TempFiles) {
    print "\nCould not remove all .tmp files form $TempDirectory please delete them manually and try again\n";
    exit 1;
}

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

# Change to OTRSCodePolicy directory to be able to load all plugins.
#   TODO: Clarify if this is still needed (it still works when it's commented out!), and remove if not.
chdir dirname($0) . "/..";

my %ActiveChildPID;
local $SIG{INT}  = sub { Stop() };
local $SIG{TERM} = sub { Stop() };

my @GlobalResults;
if ($Processes) {

    # split chunks of files for every process
    my @Chunks;
    my $ItemCount = 0;

    for my $File (@Files) {
        push @{ $Chunks[ $ItemCount++ % $Processes ] }, $File;
    }

    CHUNK:
    for my $Chunk (@Chunks) {

        # Create a child process.
        my $PID = fork;

        # Child process could not be created.
        if ( $PID < 0 ) {

            print "Unable to fork a child process for tiding!";

            last CHUNK;
        }

        # ------------------- #
        # Start child process #
        # ------------------- #

        if ( !$PID ) {

            my @Results = $TidyAll->process_paths( @{$Chunk} );

            my $ChildPID = $$;
            Storable::store( \@Results, "$TempDirectory/$ChildPID.tmp" );

            # Close child process at the end.
            exit 0;
        }

        # ----------------- #
        # End child process #
        # ----------------- #

        $ActiveChildPID{$PID} = {
            PID => $PID,
        };
    }

    # Check the status of all child processes every 0.1 seconds.
    # Wait for all child processes to be finished.
    WAIT:
    while (1) {

        last WAIT if !%ActiveChildPID;

        sleep 0.1;

        PID:
        for my $PID ( sort keys %ActiveChildPID ) {

            my $WaitResult = waitpid( $PID, WNOHANG );

            if ( $WaitResult == -1 ) {

                print "Child process '$PID' exited with errors: $?";

                delete $ActiveChildPID{$PID};

                next PID;
            }

            if ($WaitResult) {
                delete $ActiveChildPID{$PID};

                my $TempFile = "$TempDirectory/$PID.tmp";
                my $Results;

                if ( -e $TempFile ) {
                    $Results = Storable::retrieve($TempFile);
                }

                # Join the child results.
                @GlobalResults = ( @GlobalResults, @{ $Results || [] } );

                # Remove temp file.
                unlink $TempFile;
            }
        }
    }
}
else {
    $TidyAll->process_paths(@Files);
}

# Remove any temp file left.
unlink glob "'$TempDirectory/*.tmp'";

# Change working directory back.
chdir $RootDir;

my $FailMsg;
if ( my @ErrorResults = grep { $_->error() } @GlobalResults ) {
    my $ErrorCount = scalar(@ErrorResults);
    $FailMsg = sprintf(
        "%d file%s did not pass tidyall check\n",
        $ErrorCount, $ErrorCount > 1 ? "s" : ""
    );
}
die "$FailMsg\n" if $FailMsg;

sub Stop {

    # Propagate kill signal to all forks
    for my $PID ( sort keys %ActiveChildPID ) {
        kill 9, $PID;
    }

    print "Stopped by user!\n";
    return 1;
}
