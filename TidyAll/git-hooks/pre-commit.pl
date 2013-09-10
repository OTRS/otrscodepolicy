#!/usr/bin/perl
# --
# TidyAll/git-hooks/pre-commit.pl - commit hook
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
## no critic

=head1 SYNOPSIS

Slightly modified version of Code::TidyAll::Git::Precommit.
It is able to use the .tidyallrc from the main otrs-code-policy module.

=cut

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';

use Code::TidyAll::Git::Precommit;
use Cwd;
use File::Spec;

use Capture::Tiny qw(capture_stdout capture_stderr);
use Code::TidyAll;
use Code::TidyAll::Util qw(dirname mkpath realpath tempdir_simple write_file);
use Cwd qw(cwd);
use Guard;
use Log::Any qw($log);
use IPC::System::Simple qw(capturex run);
use Moo;
use Try::Tiny;

use TidyAll::OTRS;

no warnings qw(redefine);

sub Code::TidyAll::Git::Precommit::check {
    my ( $class, %params ) = @_;

    my $fail_msg;

    try {
        my $self          = $class->new(%params);
        my $tidyall_class = $self->tidyall_class;

        # Find conf file at git root
        my $root_dir = capturex( $self->git_path, "rev-parse", "--show-toplevel" );
        chomp($root_dir);

        # ---
        # OTRS
        # ---
        #        my @conf_names =
        #          $self->conf_name ? ( $self->conf_name ) : Code::TidyAll->default_conf_names;
        #        my ($conf_file) = grep { -f } map { join( "/", $root_dir, $_ ) } @conf_names
        #          or die sprintf( "could not find conf file %s", join( " or ", @conf_names ) );
        # ---
        my $ScriptDirectory;
        if ( -l $0 ) {
            $ScriptDirectory = dirname( readlink($0) );
        }
        else {
            $ScriptDirectory = dirname($0);
        }
        my $conf_file = $ScriptDirectory . '/../tidyallrc';

        # ---
        # Store the stash, and restore it upon exiting this scope
        unless ( $self->no_stash ) {
            run( $self->git_path, "stash", "-q", "--keep-index" );
            scope_guard { run( $self->git_path, "stash", "pop", "-q" ) };
        }

        # Gather file paths to be committed
        my $output = capturex( $self->git_path, "status", "--porcelain" );
        my @files = grep {-f} ( $output =~ /^[MA]\s+(.*)/gm );

        # ---
        # OTRS
        # ---
        # Change to otrs-code-policy directory to be able to load all plugins.
        my $RootDir = getcwd();
        chdir $ScriptDirectory . '/../../';
        $self->tidyall_options->{root_dir}      = $RootDir;
        $self->tidyall_options->{data_dir}      = File::Spec->tmpdir();
        $self->tidyall_options->{tidyall_class} = 'TidyAll::OTRS';

        # ---
        my $tidyall = $tidyall_class->new_from_conf_file(
            $conf_file,
            no_cache   => 1,
            check_only => 1,
            mode       => 'commit',
            %{ $self->tidyall_options },
        );

        # ---
        # OTRS
        # ---
        $tidyall->DetermineFrameworkVersionFromDirectory();

        # ---
        my @results = $tidyall->process_paths( map {"$root_dir/$_"} @files );

        # ---
        # OTRS
        # ---
        # Change working directory back.
        chdir $RootDir;

        # ---

        if ( my @error_results = grep { $_->error } @results ) {
            my $error_count = scalar(@error_results);
            $fail_msg = sprintf(
                "%d file%s did not pass tidyall check\n",
                $error_count, $error_count > 1 ? "s" : ""
            );
        }
    }
    catch {
        my $error = $_;
        die "Error during pre-commit hook (use --no-verify to skip hook):\n$error";
    };
    die "$fail_msg\n" if $fail_msg;
}

print "OTRS code policy check running...\n";
Code::TidyAll::Git::Precommit->check();
