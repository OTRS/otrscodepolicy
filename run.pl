#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use FindBin qw($RealBin);
use Code::TidyAll;

my $conf_file = dirname($0) . '/TidyAll/tidyallrc';
# Change to otrs-code-policy directory to be able to load all plugins.
my $RootDir = getcwd();
chdir dirname($0);

my $tidyall = Code::TidyAll->new_from_conf_file(
    $conf_file,
    no_cache   => 1,
    check_only => 1,
    mode       => 'cli',
    root_dir   => $RootDir,
);
my @results = $tidyall->process_all();

# Change working directory back.
chdir $RootDir;

my $fail_msg;
if ( my @error_results = grep { $_->error } @results ) {
    my $error_count = scalar(@error_results);
    $fail_msg = sprintf( "%d file%s did not pass tidyall check\n",
        $error_count, $error_count > 1 ? "s" : "" );
}
die "$fail_msg\n" if $fail_msg;
