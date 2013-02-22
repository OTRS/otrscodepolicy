#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use FindBin qw($RealBin);
use Code::TidyAll;
use File::Spec;
use Getopt::Long;
use File::Find;

my ($Verbose, $Directory);
GetOptions(
    'verbose' => \$Verbose,
    'directory=s' => \$Directory,
);

my $conf_file = dirname($0) . '/TidyAll/tidyallrc';
# Change to otrs-code-policy directory to be able to load all plugins.
my $RootDir = getcwd();

my @Files;
if (length $Directory) {
    sub Wanted {
        return if (!-f $File::Find::name);
        push @Files, $File::Find::name;
    };

    File::Find::find(
        \&Wanted,
        File::Spec->catfile($RootDir, $Directory),
    );
}

chdir dirname($0);

my $tidyall = Code::TidyAll->new_from_conf_file(
    $conf_file,
    no_cache   => 1,
    check_only => 1,
    mode       => 'cli',
    root_dir   => $RootDir,
    data_dir   => File::Spec->tmpdir(),
    verbose    => $Verbose ? 1 : 0,
);

my @results;
if (length $Directory) {
    @results = $tidyall->process_files(@Files);
}
else {
    @results = $tidyall->process_all();
}

# Change working directory back.
chdir $RootDir;

my $fail_msg;
if ( my @error_results = grep { $_->error } @results ) {
    my $error_count = scalar(@error_results);
    $fail_msg = sprintf( "%d file%s did not pass tidyall check\n",
        $error_count, $error_count > 1 ? "s" : "" );
}
die "$fail_msg\n" if $fail_msg;
