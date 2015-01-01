# --
# OTRSCodePolicy.t - code policy tests
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
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
    no_cache   => 1,
    check_only => 1,
    mode       => 'tests',
    root_dir   => $Home,
    data_dir   => File::Spec->tmpdir(),
    quiet      => 1,
);
$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

#
# We need a cache for performance reasons. This will live in /tmp to be persistent across
#   runs of our UT scenarios. Cache based on file name, content and OTRS version.
#

my $CacheDir = '/tmp/OTRSCodePolicy.t/';
my $Success = -d $CacheDir || File::Path::make_path($CacheDir);
$Self->True(
    $Success,
    "Created cache directory $CacheDir",
);
die if !$Success;

my $CacheTTLSeconds = 6 * 60 * 60;                     # 6 hours
my $Version         = $ConfigObject->Get('Version');

# Clean up old cache files first (TTL expired).
my $Wanted = sub {

    # Skip nonregular files and directories.
    return if ( !-f $File::Find::name );

    my $Stat = File::stat::stat($File::Find::name);

    if ( time() - $Stat->ctime() > $CacheTTLSeconds ) {    ## no critic
                                                           #print STDERR "Unlink cache file $File::Find::name\n";
        unlink $File::Find::name || die "Could not delete $File::Find::name";
    }
};
File::Find::find( $Wanted, $CacheDir );

FILE:
for my $File ( $TidyAll->find_matched_files() ) {

    # Check for valid cache file that represents a successful test
    my $ContentMD5 = $MainObject->MD5sum(
        Filename => $File,
    );

    my $CacheKey = $MainObject->MD5sum(
        String => "$Version:$File:$ContentMD5",
    );

    my $CacheFileName = "$CacheDir$CacheKey.ok";

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
