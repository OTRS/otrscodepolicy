# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';    # find TidyAll

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
{
    use Devel::StackTrace();
    no warnings 'redefine';
    sub Devel::StackTrace::new { }
}

use File::Find();
use File::stat();
use File::Path();
use TidyAll::OTRS;
use Cwd;

# Don't use OM so that this also works for OTRS 3.3 and lower
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;

my $ConfigObject = Kernel::Config->new();
my $EncodeObject = Kernel::System::Encode->new(
    ConfigObject => $ConfigObject,
);
my $LogObject = Kernel::System::Log->new(
    ConfigObject => $ConfigObject,
    EncodeObject => $EncodeObject,
);
my $MainObject = Kernel::System::Main->new(
    ConfigObject => $ConfigObject,
    EncodeObject => $EncodeObject,
    LogObject    => $LogObject,
);

my $OldWorkingDir = getcwd();

my $Home = $ConfigObject->Get('Home');

# Change to toplevel dir so that perlcritic finds all plugins.
chdir($Home);

my $TidyAll = TidyAll::OTRS->new_from_conf_file(
    "$Home/Kernel/TidyAll/tidyallrc",
    check_only => 1,
    mode       => 'tests',
    root_dir   => $Home,
    data_dir   => File::Spec->tmpdir(),
    quiet      => 1,
);
$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

#
# We need a cache for performance reasons. This will live in /var/otrs-unittest (fallback to /tmp)
#   to be persistent across runs of our UT scenarios. Cache based on file name, content and OTRS version.
#
# We don't need to perform cache cleanup here, this will be done by the CI provisioner instead.
#

my $CacheDir = -d '/var/otrs-unittest' ? '/var/otrs-unittest' : '/tmp';
$CacheDir .= '/OTRSCodePolicy.t/';
my $Success = -d $CacheDir || File::Path::make_path($CacheDir);
$Self->True(
    $Success,
    "Created cache directory $CacheDir",
);
die if !$Success;

#
# Get a cache version MD5 string that changes when the OTRSCodePolicy module changes.
#   We do this by getting all file names and contents in Kernel/TidyAll and computing an MD5 on it.
#   This is not perfect, but probably good enough.
#
my $CacheVersionString;

# Collect all CodePolicy files and their contents (timestamps not relevant)
my $WantedCodePolicy = sub {

    # Skip hidden directories.
    return if substr( $File::Find::name, 0, 1 ) eq '.';

    # Skip nonregular files and directories.
    return if ( !-f $File::Find::name );
    my $ContentRef = $MainObject->FileRead(
        Location => $File::Find::name,
        Mode     => 'utf8',
    );
    die if !ref $ContentRef;
    $CacheVersionString .= "$File::Find::name:$$ContentRef:";
};
File::Find::find( $WantedCodePolicy, $ConfigObject->Get('Home') . '/Kernel/TidyAll' );

my $CacheVersionMD5 = $MainObject->MD5sum(
    String => $CacheVersionString,
);

#
# Now perform the real file validation.
#

my $Version = $ConfigObject->Get('Version');

FILE:
for my $File ( $TidyAll->find_matched_files() ) {

    next FILE if $File =~ m{oradiag};    # ignore Oracle log files

    # Check for valid cache file that represents a successful test
    my $ContentMD5 = $MainObject->MD5sum(
        Filename => $File,
    );

    my $CacheKey = $MainObject->MD5sum(
        String => "$Version:$CacheVersionMD5:$File:$ContentMD5",
    );

    # Put hash files in subdirs to avoid having too many files in one directory.
    my $SubDir = substr( $CacheKey, 0, 2 );
    if ( !-d "$CacheDir/$SubDir" ) {
        File::Path::make_path("$CacheDir/$SubDir") || die "Could not create $CacheDir/$SubDir: $!";
    }

    my $CacheFileName = "$CacheDir/$SubDir/$CacheKey.ok";

    if ( -e $CacheFileName ) {
        $Self->Is(
            'checked',
            'checked',
            "$File check results [cached]",
        );
        next FILE;
    }

    # No cache available
    my $Result = $TidyAll->process_file($File);

    next FILE if $Result->state() eq 'no_match';    # no plugins apply, ignore file

    $Self->Is(
        $Result->state(),
        'checked',
        "$File check results " . ( $Result->error() || '' ),
    );

    # Write cache file for successful results
    if ( $Result->state() eq 'checked' ) {
        $MainObject->FileWrite(
            Location => $CacheFileName,
            Content  => \'',
        );
    }
}

# Change back to previous working directory.
chdir($OldWorkingDir);

1;
