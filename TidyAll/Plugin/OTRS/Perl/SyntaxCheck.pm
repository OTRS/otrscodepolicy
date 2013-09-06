package TidyAll::Plugin::OTRS::Perl::SyntaxCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use File::Temp;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled(Code => $Code);

    my ($CleanedSource, $DeletableStatement);

    LINE:
    for my $Line ( split(/\n/, $Code) ) {

        $Line =~ s{\[gettimeofday\]}{1}smx;

        # We'll skip all use *; statements exept a few because the modules cannot all be found at runtime.
        if (
            $Line =~ m{ \A \s* use \s+ }xms
            && $Line !~ m{\A \s* use \s+ (?: vars | constant | strict | warnings | Data (?! ::Validate ) | threads | Readonly | lib | FindBin | IO::Socket | File::Basename | Moo | Perl::Critic | UUID::Tiny | Cwd | POSIX ) }xms
        )
        {
            $DeletableStatement = 1;
        }

        if ($DeletableStatement) {
            $Line = "#$Line";
        }

        if ($Line =~ m{ ; \s* \z }xms) {
            $DeletableStatement = 0;
        }

        $CleanedSource .= $Line . "\n";
    }

    #print STDERR $CleanedSource;

    my $TempFile = File::Temp->new();
    print $TempFile $CleanedSource;
    $TempFile->flush();

    # syntax check
    my $ErrorMessage;
    my $FileHandle;
    if (!open $FileHandle, '-|', "perl -cw " . $TempFile->filename() . " 2>&1") {
        die __PACKAGE__ . "\nFILTER: Can't open tempfile: $!\n";
    }

    while (my $Line = <$FileHandle>) {
        if ($Line !~ /(syntax OK|used only once: possible typo)/) {
            $ErrorMessage .= $Line;
        }
    }
    close $FileHandle;

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
