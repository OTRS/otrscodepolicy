# --
# OTRSCodePolicy.t - code policy tests
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
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
use lib dirname($RealBin) . '/Kernel/'; # find TidyAll

use File::Find;
use TidyAll::OTRS;
use Cwd;

use Kernel::Config;

my $ConfigObject = Kernel::Config->new();

# Get all files in the OTRS directory
my $Home = $ConfigObject->Get('Home');
my @Files;
my $Wanted = sub {

    # Skip non-regular files and directories.
    return if ( !-f $File::Find::name );

    # Also skip symbolic links, TidyAll does not like them.
    return if ( -l $File::Find::name );
    push @Files, $File::Find::name;
};
File::Find::find( $Wanted, $Home );

my $OldWorkingDir = getcwd();

# Change to toplevel dir so that perlcritic finds all plugins.
chdir($Home);

my $TidyAll = TidyAll::OTRS->new_from_conf_file(
    "$Home/Kernel/TidyAll/tidyallrc",
    no_cache   => 1,
    check_only => 1,
    mode       => 'tests',
    root_dir   => $Home,
    data_dir   => File::Spec->tmpdir(),

    #verbose    => 1,
);
$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

FILE:
for my $File (@Files) {

    my $Result = $TidyAll->process_file($File);

    next FILE if $Result->state() eq 'no_match';    # no plugins apply, ignore file

    $Self->IsNot(
        $Result->state(),
        'error',
        "$File check results " . ( $Result->error() || '' ),
    );
}

# Change back to previous working directory.
chdir($OldWorkingDir);

1;
