# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::OTRS::Git::PreCommit;

use strict;
use warnings;

=head1 SYNOPSIS

This commit hook loads the OTRS version of Code::TidyAll
with the custom plugins, executes it for any modified files
and returns a corresponding status code.

=cut

use Cwd;
use File::Spec;
use File::Basename;

use Code::TidyAll;
use IPC::System::Simple qw(capturex run);
use Try::Tiny;
use TidyAll::OTRS;
use Moo;

sub Run {
    my $Self = @_;

    print "OTRSCodePolicy commit hook starting...\n";

    my $ErrorMessage;

    try {
        # Find conf file at git root
        my $RootDir = capturex( 'git', "rev-parse", "--show-toplevel" );
        chomp($RootDir);

        # Gather file paths to be committed
        my $Output = capturex( 'git', "status", "--porcelain" );

        # Fetch only staged files that will be committed.
        my @ChangedFiles = grep { -f && !-l } ( $Output =~ /^[MA]+\s+(.*)/gm );
        push @ChangedFiles, grep { -f && !-l } ( $Output =~ /^\s*RM?+\s+(.*?)\s+->\s+(.*)/gm );
        return if !@ChangedFiles;

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( map { File::Spec->abs2rel( $_, $RootDir ) } grep { !-l $_ } glob("$RootDir/*.sopm") ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        # Find OTRSCodePolicy configuration
        my $ScriptDirectory;
        if ( -l $0 ) {
            $ScriptDirectory = dirname( readlink($0) );
        }
        else {
            $ScriptDirectory = dirname($0);
        }
        my $ConfigFile = $ScriptDirectory . '/../tidyallrc';

        my $TidyAll = TidyAll::OTRS->new_from_conf_file(
            $ConfigFile,
            check_only => 1,
            mode       => 'commit',
            root_dir   => $RootDir,
            data_dir   => File::Spec->tmpdir(),
        );
        $TidyAll->DetermineFrameworkVersionFromDirectory();
        $TidyAll->GetFileListFromDirectory();

        my @CheckResults = $TidyAll->ProcessPathsParallel(
            FilePaths => [ map {"$RootDir/$_"} @ChangedFiles ],
        );

        $TidyAll->HandleResults(
            Results => \@CheckResults,
        );
    }
    catch {
        my $Exception = $_;
        die "Error during pre-commit hook (use --no-verify to skip hook):\n$Exception";
    };
    if ($ErrorMessage) {
        die "$ErrorMessage\nYou can use --no-verify to skip the hook\n";
    }
}

1;
