# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Legal::ReplaceCopyright;
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't replace copyright in thirdparty code.
    return $Code if $Self->IsThirdpartyModule();

    my $Copy      = 'OTRS AG, http://otrs.com/';
    my $StartYear = 2001;

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );    ## no critic
    $Year += 1900;

    my $YearString = "$StartYear-$Year";
    if ( $StartYear == $Year ) {
        $YearString = $Year;
    }

    my $Output = '';

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        if ( $Line !~ m{Copyright}smx ) {
            $Output .= $Line . "\n";
            next LINE;
        }

        # special settings for the language directory
        if ( $Line !~ m{OTRS}smx && $Code =~ m{ package \s+ Kernel::Language:: }smx ) {
            $Output .= $Line . "\n";
            next LINE;
        }

        # for the commandline help
        # e.g : print "Copyright (c) 2003-2008 OTRS AG, http://www.otrs.com/\n";
        if ( $Line !~ m{ ^\# \s Copyright }smx ) {
            if (
                $Line
                =~ m{ ^ ( [^\n]* ) Copyright [ ]+ \( [Cc] \) .+? OTRS [ ]+ (?: AG | GmbH ), [ ]+ http:\/\/otrs\. (?: org | com ) \/? }smx
                )
            {
                $Line =~ s{
                     ^ ( [^\n]* ) Copyright [ ]+ \( [Cc] \) .+? OTRS [ ]+ (?: AG | GmbH ), [ ]+ http:\/\/otrs\. (?: org | com ) \/?
                 }
                 {$1Copyright (C) $YearString $Copy}smx;
            }
            $Output .= $Line . "\n";
            next LINE;
        }

        # check string in the comment line
        if ( $Line !~ m{^\# \s Copyright \s \( C \) \s $YearString \s $Copy$}smx ) {
            $Line = "# Copyright (C) $YearString $Copy";
        }

        $Output .= $Line . "\n";
    }

    return $Output;
}

1;
