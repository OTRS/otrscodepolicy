# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
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
no warnings 'redefine';    ## no critic
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

use File::Spec();
use TidyAll::OTRS;

# Don't use OM so that this also works for OTRS 3.3 and lower
use Kernel::Config;

my $ConfigObject = Kernel::Config->new();
my $Home         = $ConfigObject->Get('Home');

# Suppress colored output to not clutter log files.
local $ENV{OTRSCODEPOLICY_NOCOLOR} = 1;

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
# Now perform the real file validation.
#

# Don't use TidyAll::process_all() or TidyAll::find_matched_files() as it is too slow on large code bases.
my @Files = $TidyAll->FilterMatchedFiles( Files => \@TidyAll::OTRS::FileList );
@Files = map { File::Spec->catfile( $Home, $_ ) } @Files;

FILE:
for my $File (@Files) {

    # Ignore Oracle log files.
    next FILE if $File =~ m{oradiag};

    my $Result = $TidyAll->process_file($File);

    next FILE if $Result->state() eq 'no_match';    # no plugins apply, ignore file

    $Self->Is(
        $Result->state(),
        'checked',
        "$File check results " . ( $Result->error() || '' ),
    );
}

1;
