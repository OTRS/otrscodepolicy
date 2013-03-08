# --
# OTRSCodePolicy.t - code policy tests
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;
use vars (qw($Self));
use utf8;
use Kernel::Config;
use File::Find;
use Code::TidyAll;
use Cwd;

my $ConfigObject = Kernel::Config->new();

my $Home = $ConfigObject->Get('Home');
my @Files;

my $Wanted = sub {
    return if ( !-f $File::Find::name );
    push @Files, $File::Find::name;
};

my $OldWorkingDir = getcwd();

# Change to toplevel dir so that perlcritic finds all plugins.
chdir($Home);

File::Find::find( $Wanted, $Home );

my $TidyAll = Code::TidyAll->new_from_conf_file(
    "$Home/TidyAll/tidyallrc",
    no_cache   => 1,
    check_only => 1,
    mode       => 'tests',
    root_dir   => $Home,
    data_dir   => File::Spec->tmpdir(),

    #verbose    => 1,
);

my $I;

FILE:
for my $File (@Files) {
    my $Result = $TidyAll->process_file($File);

    next FILE if $Result->state() eq 'no_match';    # no plugins apply, ignore file

    $Self->IsNot(
        $Result->state(),
        'error',
        "$File check results " . ( $Result->error() || '' ),
    );

    last if $I++ > 100;

}

# Change back to previous working directory.
chdir($OldWorkingDir);

1;
