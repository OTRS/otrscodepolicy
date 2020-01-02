# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::OTRS;

use strict;
use warnings;

use IO::File;
use parent qw(Code::TidyAll);

# Require some needed modules here for clarity / better error messages.
use Code::TidyAll 0.56;
use Perl::Critic;
use Perl::Tidy;

our $FrameworkVersionMajor = 0;
our $FrameworkVersionMinor = 0;
our $ThirdpartyModule      = 0;
our @FileList              = ();    # all files in current repository

sub new_from_conf_file {            ## no critic
    my ( $Class, $ConfigFile, %Param ) = @_;

    my $Self = $Class->SUPER::new_from_conf_file(
        $ConfigFile,
        %Param,
        no_cache   => 1,
        no_backups => 1,
    );

    # Reset when a new object is created
    $FrameworkVersionMajor = 0;
    $FrameworkVersionMinor = 0;
    $ThirdpartyModule      = 0;
    @FileList              = ();

    return $Self;
}

sub DetermineFrameworkVersionFromDirectory {
    my ( $Self, %Param ) = @_;

    # First check if we have an OTRS directory, use RELEASE info then.
    if ( -r $Self->{root_dir} . '/RELEASE' ) {
        my $FileHandle = IO::File->new( $Self->{root_dir} . '/RELEASE', 'r' );
        my @Content    = $FileHandle->getlines();

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $FrameworkVersionMajor = $VersionMajor;
        $FrameworkVersionMinor = $VersionMinor;
    }
    else {
        # Now check if we have a module directory with an SOPM file in it.
        my @SOPMFiles = glob $Self->{root_dir} . "/*.sopm";
        if (@SOPMFiles) {

            # Use the highest framework version from the first SOPM file.
            my $FileHandle = IO::File->new( $SOPMFiles[0], 'r' );
            my @Content    = $FileHandle->getlines();
            for my $Line (@Content) {
                if ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > }xms ) {
                    my ( $VersionMajor, $VersionMinor )
                        = $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > (\d+) \. (\d+) \. [^<*]+ <\/Framework> }xms;
                    if (
                        $VersionMajor > $FrameworkVersionMajor
                        || (
                            $VersionMajor == $FrameworkVersionMajor
                            && $VersionMinor > $FrameworkVersionMinor
                        )
                        )
                    {
                        $FrameworkVersionMajor = $VersionMajor;
                        $FrameworkVersionMinor = $VersionMinor;
                    }
                }
                elsif ( $Line =~ m{<Vendor>} && $Line !~ m{OTRS} ) {
                    $ThirdpartyModule = 1;
                }
            }
        }
    }

    if ($FrameworkVersionMajor) {
        print "Found OTRS version $FrameworkVersionMajor.$FrameworkVersionMinor.\n";
    }
    else {
        print "Could not determine OTRS version (assuming latest version)!\n";
    }

    if ($ThirdpartyModule) {
        print
            "This seems to be a module not copyrighted by OTRS AG. File copyright will not be changed.\n";
    }
    else {
        print
            "This module seems to be copyrighted by OTRS AG. File copyright will automatically be assigned to OTRS AG.\n";
        print
            "  If this is not correct, you can change the <Vendor> tag in your SOPM.\n";
    }

    return;
}

#
# Get a list (almost) all relative file paths from the root directory. This list is used in some plugins to make validation decisions,
#   not for the actual decision which files are to be validated.
#
sub GetFileListFromDirectory {
    my ( $Self, %Param ) = @_;

    # Only run once.
    return if @FileList;

    @FileList = $Self->FindFilesInDirectory( Directory => $Self->{root_dir} );

    return;
}

#
# Get a list of all relative file paths in a directory with some global ignores for speed's sake.
#
sub FindFilesInDirectory {
    my ( $Self, %Param ) = @_;

    my $Directory = $Param{Directory};

    my @Files;

    my $Wanted = sub {

        # Skip non-regular files and directories.
        return if ( !-f $File::Find::name );

        # Also skip symbolic links, TidyAll does not like them.
        return if ( -l $File::Find::name );

        # Some global hard ignores that are meant to speed up the loading process,
        #   as applying the TidyAll ignore/select rules can be quite slow.
        return if $File::Find::name =~ m{/\.git/};
        return if $File::Find::name =~ m{/\.tidyall.d/};
        return if $File::Find::name =~ m{/\.vscode/};
        return if $File::Find::name =~ m{/node_modules/};
        return if $File::Find::name =~ m{/js-cache/};
        return if $File::Find::name =~ m{/css-cache/};
        return if $File::Find::name =~ m{/var/tmp/} && $File::Find::name !~ m{.*\.sample$};
        return if $File::Find::name =~ m{/var/public/dist/};

        push @Files, File::Spec->abs2rel( $File::Find::name, $Self->{root_dir} );
    };

    File::Find::find(
        $Wanted,
        $Directory,
    );

    return @Files;
}

#
# Filter relative file paths for only the files that are matched by at least one plugin.
#
sub FilterMatchedFiles {
    my ( $Self, %Param ) = @_;

    return grep { $Self->plugins_for_path($_) } @{ $Param{Files} };
}

1;
