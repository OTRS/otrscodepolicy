# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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

        # Find OTRSCodePolicy configuration
        my $ScriptDirectory;
        if ( -l $0 ) {
            $ScriptDirectory = dirname( readlink($0) );
        }
        else {
            $ScriptDirectory = dirname($0);
        }
        my $ConfigFile = $ScriptDirectory . '/../tidyallrc';

        # Change to otrs-code-policy directory to be able to load all plugins.
        chdir $ScriptDirectory . '/../../';

        my $TidyAll = TidyAll::OTRS->new_from_conf_file(
            $ConfigFile,
            check_only => 1,
            mode       => 'commit',
            root_dir   => $RootDir,
            data_dir   => File::Spec->tmpdir(),
        );
        $TidyAll->DetermineFrameworkVersionFromDirectory();
        $TidyAll->GetFileListFromDirectory();

        my @CheckResults = $TidyAll->process_paths( map {"$RootDir/$_"} @ChangedFiles );

        if ( my @ErrorResults = grep { $_->error() } @CheckResults ) {
            my $ErrorCount = scalar(@ErrorResults);
            $ErrorMessage = sprintf(
                "%d file%s did not pass TidyAll check\n",
                $ErrorCount,
                $ErrorCount > 1 ? "s" : ""
            );
        }
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
