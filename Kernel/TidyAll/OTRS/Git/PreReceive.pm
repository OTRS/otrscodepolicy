# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
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

    # auto-generated documentation
    'otrs-github-io.git' => 1,    # deprecated
    'doc-otrs-com.git'   => 1,

    # documentation toolchain
    'docbuild.git' => 1,

    # Thirdparty code
    'bugs-otrs-org.git' => 1,

    # OTRS Blog
    'blog-otrs-com.git' => 1,

    # OTRS Blog
    'www-otrs-com.git' => 1,

    # OTRSTube
    'clips-otrs-com.git' => 1,

    # Internal UX/UI team repository
    'ux-ui.git' => 1,

    # Streamline icons repository
    'streamline-icons.git' => 1,

    # CKEditor 5 custom build repository
    'ckeditor5-build-inline-otrs.git' => 1,

    # OTRS Mobile App repository
    'otrs-mobile-app.git' => 1,

    # VueTreeselect custom build repository
    'vue-treeselect-otrs.git' => 1,

    # GSD Tools repository
    'gsd-tools.git' => 1,
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $ErrorMessage;
    try {

        print "OTRSCodePolicy pre receive hook starting...\n";

        my $Input = $Param{Input};
        if ( !$Input ) {
            $Input = do { local $/ = undef; <> };
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
        print STDERR "*** Error running pre-receive hook (allowing push to proceed):\n$Exception";
    };
    if ($ErrorMessage) {
        print STDERR "$ErrorMessage\n";
        print STDERR "*** Push was rejected. Please fix the errors and try again. ***\n";
        exit 1;
    }
}

sub HandleInput {
    my ( $Self, $Input ) = @_;

    my @Lines = split( m/\n/, $Input );

    my (@Results);

    LINE:
    for my $Line (@Lines) {
        chomp($Line);
        my ( $Base, $Commit, $Ref ) = split( m/\s+/, $Line );

        if ( $Commit =~ m/^0+$/ ) {

            # No target commit (branch / tag delete).
            next LINE;
        }

        if ( substr( $Ref, 0, 9 ) eq 'refs/tags' ) {

            # Only allow "rel-*" as name for new and updated tags.
            if ( $Ref !~ m{ \A refs/tags/rel-\d+_\d+_\d+ (_alpha\d+ | _beta\d+ | _rc\d+)? \z }xms ) {

                my $ErrorMessage
                    = "Error: found invalid tag '$Ref' - please only use rel-A_B_C or rel-A_B_C_(alpha|beta|rc)D.";
                return $ErrorMessage;
            }

            # Valid tag.
            next LINE;
        }

        print "Checking framework version for $Ref... ";

        my @FileList = $Self->GetGitFileList($Commit);

        # Create tidyall for each branch separately
        my $TidyAll = $Self->CreateTidyAll( $Commit, \@FileList );

        my @ChangedFiles = $Self->GetChangedFiles( $Base, $Commit );

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( grep { $_ =~ m{\.sopm$} } @FileList ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        push @Results, $TidyAll->ProcessParallel(
            Processes => 2,
            FilePaths => \@ChangedFiles,
            Handler   => sub {
                my @HandlerFiles = @_;

                my @HandlerResults;

                FILE:
                for my $File (@HandlerFiles) {

                    # Don't try to validate deleted files.
                    if ( !grep { $_ eq $File } @FileList ) {
                        print "$File was deleted, ignoring.\n";
                        next FILE;
                    }

                    # Get file from git repository, one by one only as the commits could be huge.
                    my $Contents = $Self->GetGitFileContents( $File, $Commit );

                    # Only validate files which actually have some content.
                    if ( $Contents =~ /\S/ && $Contents =~ /\n/ ) {
                        push( @HandlerResults, $TidyAll->process_source( $Contents, $File ) );
                    }
                }

                return @HandlerResults;
            },
        );

    }

    if ( my @ErrorResults = grep { $_->error() } @Results ) {
        return sprintf( "Error: %d file(s) did not pass validation", scalar(@ErrorResults) );
    }

    return;
}

sub CreateTidyAll {
    my ( $Self, $Commit, $FileList ) = @_;

    # Find OTRSCodePolicy configuration
    my $ConfigFile = dirname(__FILE__) . '/../../tidyallrc';

    my $TidyAll = TidyAll::OTRS->new_from_conf_file(
        $ConfigFile,
        check_only => 1,
        mode       => 'commit',
    );

    # We cannot use these functions here because we have a bare git repository,
    #   so we have to do it on our own.
    #$TidyAll->DetermineFrameworkVersionFromDirectory();
    #$TidyAll->GetFileListFromDirectory();

    # Set the list of files to be checked
    @TidyAll::OTRS::FileList = @{$FileList};

    # Now we try to determine the OTRS version from the commit

    # Look for a RELEASE file first to determine the framework version
    if ( grep { $_ eq 'RELEASE' } @{$FileList} ) {
        my @Content = split /\n/, $Self->GetGitFileContents( 'RELEASE', $Commit );

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $TidyAll::OTRS::FrameworkVersionMajor = $VersionMajor;
        $TidyAll::OTRS::FrameworkVersionMinor = $VersionMinor;
    }

    # Look for any SOPM files
    else {
        FILE:
        for my $File ( @{$FileList} ) {
            if ( substr( $File, -5, 5 ) eq '.sopm' ) {
                my @Content = split /\n/, $Self->GetGitFileContents( $File, $Commit );

                for my $Line (@Content) {
                    if ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > }xms ) {
                        my ( $VersionMajor, $VersionMinor )
                            = $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > (\d+) \. (\d+) \. [^<*]+ <\/Framework> }xms;
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
                    elsif ( $Line =~ m{<Vendor>} && $Line !~ m{OTRS} ) {
                        $TidyAll::OTRS::ThirdpartyModule = 1;
                    }
                }

                last FILE;
            }
        }
    }

    if ($TidyAll::OTRS::FrameworkVersionMajor) {
        print
            "Found OTRS version $TidyAll::OTRS::FrameworkVersionMajor.$TidyAll::OTRS::FrameworkVersionMinor\n";
    }
    else {
        print "Could not determine OTRS version (assuming latest version)!\n";
    }

    if ($TidyAll::OTRS::ThirdpartyModule) {
        print
            "This seems to be a module not copyrighted by OTRS AG. File copyright will not be changed.\n";
    }
    else {
        print
            "This module seems to be copyrighted by OTRS AG. File copyright will automatically be assigned to OTRS AG.\n";
        print
            "  If this is not correct, you can change the <Vendor> tag in your SOPM.\n";
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

    # Only use the last commit if we have a new branch.
    #   This is not perfect, but otherwise quite complicated.
    if ( $Base =~ m/^0+$/ ) {
        my $Output = capturex( 'git', 'diff-tree', '--no-commit-id', '--name-only', '-r', $Commit );
        my @Files  = grep {/\S/} split( m/\n/, $Output );
        return @Files;
    }

    my $Output = capturex( 'git', "diff", "--numstat", "--name-only", "$Base..$Commit" );
    my @Files  = grep {/\S/} split( m/\n/, $Output );
    return @Files;
}

1;
