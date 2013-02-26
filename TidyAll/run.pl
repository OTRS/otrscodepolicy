#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use Getopt::Long;
use File::Find;
use Code::TidyAll;
use Code::TidyAll::Git::Util;

my ( $Verbose, $Directory, $All, $Help );
GetOptions(
    'verbose'     => \$Verbose,
    'all'         => \$All,
    'directory=s' => \$Directory,
    'help' => \$Help,
);

if ($Help) {
    print <<EOF;
Usage: otrs-code-policy/run.pl [options]

    Performs OTRS code policy checks. Run this script from the toplevel directory
    of your module. By default it will only process files which are staged for
    git commit. Use --all or --directory to check all files or just one directory
    instead.

Options:
    -a, --all           Check all files recursively
    -d, --directory     Check only subdirectory
    -v, --verbose       Activate diagnostics
    -h, --help          Show this usage message
EOF
    exit 0;
}

my $conf_file = dirname($0) . '/tidyallrc';

# Change to otrs-code-policy directory to be able to load all plugins.
my $RootDir = getcwd();

my @Files;
if ( length $Directory ) {

    my $Wanted = sub {
        return if ( !-f $File::Find::name );
        push @Files, $File::Find::name;
    };

    File::Find::find(
        $Wanted,
        File::Spec->catfile( $RootDir, $Directory ),
    );
}
elsif (!$All) {
    @Files = Code::TidyAll::Git::Util::git_uncommitted_files( $RootDir );
}

chdir dirname($0 . "/..");

my $TidyAll = Code::TidyAll->new_from_conf_file(
    $conf_file,
    no_cache   => 1,
    check_only => 0,
    mode       => 'cli',
    root_dir   => $RootDir,
    data_dir   => File::Spec->tmpdir(),
    verbose    => $Verbose ? 1 : 0,
);

my @Results;
if ( !$All ) {
    @Results = $TidyAll->process_files(@Files);
}
else {
    @Results = $TidyAll->process_all();
}

# Change working directory back.
chdir $RootDir;

my $FailMsg;
if ( my @ErrorResults = grep { $_->error } @Results ) {
    my $ErrorCount = scalar(@ErrorResults);
    $FailMsg = sprintf(
        "%d file%s did not pass tidyall check\n",
        $ErrorCount, $ErrorCount > 1 ? "s" : ""
    );
}
die "$FailMsg\n" if $FailMsg;
