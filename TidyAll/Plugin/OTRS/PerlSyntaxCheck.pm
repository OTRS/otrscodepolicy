package TidyAll::Plugin::OTRS::PerlSyntaxCheck;

use strict;
use warnings;

BEGIN {
  $TidyAll::Plugin::OTRS::PerlSyntaxCheck::VERSION = '0.1';
}
use base qw(TidyAll::Plugin::OTRS::PluginBase);

use File::Temp;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->is_disabled(Code => $Code);

    my $TempFile = File::Temp->new();

    my $CleanedSource;

    LINE:
    for my $Line ( split(/\n/, $Code) ) {

        $Line =~ s{\[gettimeofday\]}{1}smx;

        # We'll skip all use *; statements exept a few because the modules cannot all be found
        # at runtime.
        if (
            $Line =~ m{ \A \s* use }xms
            && $Line !~ m{\A \s* use \s+ (?: vars | constant | strict | warnings | Data (?! ::Validate ) | threads | Readonly | lib | FindBin | IO::Socket | File::Basename | Moo | Perl::Critic | Cwd ) }xms
        )
        {
            $Line = "#$Line";
        }
        $CleanedSource .= $Line . "\n";
    }

    print $TempFile $CleanedSource;
    $TempFile->flush();

    # syntax check
    my $ErrorMessage;
    open my $In, '-|', "perl -cw " . $TempFile->filename() . " 2>&1" or die "FILTER: Can't open tempfile: $!\n";
    while (my $Line = <$In>) {
        if ($Line !~ /(syntax OK|used only once: possible typo)/) {
            $ErrorMessage .= $Line;
        }
    }
    close $In;

    die $ErrorMessage if ($ErrorMessage);
}

1;
