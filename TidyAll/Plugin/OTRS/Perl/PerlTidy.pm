# --
# TidyAll/Plugin/OTRS/Perl/PerlTidy.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PerlTidy;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Perl);

use Capture::Tiny qw(capture_merged);
use Perl::Tidy;

sub transform_source { ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    # Don't modify files which are derived files (have change markers).
    if ( $Code =~ m{ \$OldId: | ^ \# \s* \$origin: }xms ) {
        return $Code;
    }

    # perltidy reports errors in two different ways.
    # Argument/profile errors are output and an error_flag is returned.
    # Syntax errors are sent to errorfile.
    #
    my ( $Output, $ErrorFlag, $ErrorFile, $Destination );
    $Output = capture_merged {
        $ErrorFlag = Perl::Tidy::perltidy(
            argv        => $Self->argv(),
            source      => \$Code,
            destination => \$Destination,
            errorfile   => \$ErrorFile
        );
    };
    if ($ErrorFile) {
        die __PACKAGE__ . "\n$ErrorFile";
    }
    if ($ErrorFlag) {
        die __PACKAGE__ . "\n$Output";
    }
    if ( defined $Output ) {
        print STDERR $Output;
    }
    return $Destination;
}

1;
