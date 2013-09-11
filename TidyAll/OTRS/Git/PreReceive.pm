# --
# TidyAll/OTRS/Git/PreReceive.pm - PreReceive hook
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::OTRS::Git::PreReceive;

use strict;
use warnings;

=head1 SYNOPSIS

This pre receive hook loads the OTRS version of Code::TidyAll
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

# Ignore these repositories on the server so that we can always push to them.
my %IgnoreRepositories = (
    'otrscodepolicy.git' => 1,
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $ErrorMessage;
    try {

        print "OTRSCodePolicy pre receive hook starting...\n";

        my $Input = $Param{Input};
        if ( !$Input ) {
            $Input = do { local $/; <STDIN> };
        }

        # Debug
        #print "Got data:\n$Input";

        my $RootDirectory = Cwd::realpath();
        local $ENV{GIT_DIR} = $RootDirectory;

        my $RepositoryName = [ split m{/}, $RootDirectory ]->[-1];
        if ( $IgnoreRepositories{$RepositoryName} ) {
            print "Skipping checks for repository $RepositoryName.\n";
            return;
        }

        $ErrorMessage = $Self->HandleInput($Input);
    }
    catch {
        my $Exception = $_;

        #die $Exception;
        print STDERR "*** Error running pre-receive hook (allowing push to proceed):\n$Exception";
    };
    if ($ErrorMessage) {
        print "$ErrorMessage\n";
        print "Push still accepted until real checks are activated.\n";
    }
}

sub HandleInput {
    my ( $Self, $Input ) = @_;

    my @Lines = split( "\n", $Input );

    my (@Results);

    for my $Line (@Lines) {
        chomp($Line);
        my ( $Base, $Commit, $Ref ) = split( /\s+/, $Line );

        print "Checking framework version for $Ref... ";

        # Create tidyall for each branch separately
        my $TidyAll = $Self->CreateTidyAll($Commit);

        my @ChangedFiles = $Self->GetChangedFiles( $Base, $Commit );
        for my $File (@ChangedFiles) {
            my $Contents = $Self->GetGitFileContents( $File, $Commit );
            if ( $Contents =~ /\S/ && $Contents =~ /\n/ ) {
                push( @Results, $TidyAll->process_source( $Contents, $File ) );
            }
        }
    }

    my $ErrorMessage;
    if ( my @ErrorResults = grep { $_->error() } @Results ) {
        my $ErrorCount = scalar(@ErrorResults);
        $ErrorMessage = sprintf(
            "%d file%s did not pass tidyall check",
            $ErrorCount,
            $ErrorCount > 1 ? "s" : ""
        );
    }

    return $ErrorMessage;
}

sub CreateTidyAll {
    my ( $Self, $Commit ) = @_;

    # Find OTRSCodePolicy configuration
    my $ConfigFile = dirname(__FILE__) . '/../../tidyallrc';

    my $TidyAll = TidyAll::OTRS->new_from_conf_file(
        $ConfigFile,
        mode       => 'commit',
        #quiet      => 1,
        no_cache   => 1,
        no_backups => 1,
        check_only => 1,
    );

    # Now we try to determine the OTRS version from the commit
    my @FileList = $Self->GetGitFileList($Commit);

    # Look for a RELEASE file first to determine the framework version
    if ( grep { $_ eq 'RELEASE' } @FileList ) {
        my @Content = split /\n/, $Self->GetGitFileContents( 'RELEASE', $Commit );

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $TidyAll::OTRS::FrameworkVersionMajor = $VersionMajor;
        $TidyAll::OTRS::FrameworkVersionMinor = $VersionMinor;
    }

    # Look for any SOPM files
    else {
        FILE:
        for my $File (@FileList) {
            if ( substr( $File, -5, 5 ) eq '.sopm' ) {
                my @Content = split /\n/, $Self->GetGitFileContents( $File, $Commit );

                for my $Line (@Content) {
                    if ( $Line =~ m{<Framework>} ) {
                        my ( $VersionMajor, $VersionMinor )
                            = $Line =~ m{<Framework>(\d+)\.(\d+)\.[^<*]</Framework>}xms;
                        if (
                            $VersionMajor > $TidyAll::OTRS::FrameworkVersionMajor
                            || (
                                $VersionMajor == $TidyAll::OTRS::FrameworkVersionMajor
                                && $VersionMinor > $TidyAll::OTRS::FrameworkVersionMinor
                            )
                            )
                        {
                            $TidyAll::OTRS::FrameworkVersionMajor = $VersionMajor;
                            $TidyAll::OTRS::FrameworkVersionMinor = $VersionMinor;
                        }
                    }
                }

                last FILE;
            }
        }
    }

    if ($TidyAll::OTRS::FrameworkVersionMajor) {
        print
            "found OTRS version $TidyAll::OTRS::FrameworkVersionMajor.$TidyAll::OTRS::FrameworkVersionMinor\n";
    }
    else {
        print "could not determine OTRS version!\n";
    }

    return $TidyAll;
}

sub GetGitFileContents {
    my ( $Self, $File, $Commit ) = @_;
    my $Content = capturex( "git", "show", "$Commit:$File" );
    return $Content;
}

sub GetGitFileList {
    my ( $Self, $Commit ) = @_;
    my $Output = capturex( "git", "ls-tree", "--name-only", "-r", "$Commit" );
    return split /\n/, $Output;
}

sub GetChangedFiles {
    my ( $Self, $Base, $Commit ) = @_;
    my $Output = capturex( 'git', "diff", "--numstat", "--name-only", "$Base..$Commit" );
    my @Files = grep {/\S/} split( "\n", $Output );
    return @Files;
}

1;
