package TidyAll::Plugin::OTRS::Perl::PerlTidy;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

use Capture::Tiny qw(capture_merged);
use Perl::Tidy;

sub transform_source {
    my ( $Self, $Source ) = @_;

    # Don't modify files which are derived files (have change markers).
    if ( $Source =~ m{ \$OldId: | ^ \# \s* \$origin: }xms ) {
        return $Source;
    }

    # perltidy reports errors in two different ways.
    # Argument/profile errors are output and an error_flag is returned.
    # Syntax errors are sent to errorfile.
    #
    my ( $Output, $ErrorFlag, $ErrorFile, $Destination );
    $Output = capture_merged {
        $ErrorFlag = Perl::Tidy::perltidy(
            argv        => $Self->argv,
            source      => \$Source,
            destination => \$Destination,
            errorfile   => \$ErrorFile
        );
    };
    die $ErrorFile       if $ErrorFile;
    die $Output          if $ErrorFlag;
    print STDERR $Output if defined($Output);
    return $Destination;
}

1;
