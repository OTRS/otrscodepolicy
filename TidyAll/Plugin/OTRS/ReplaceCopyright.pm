package TidyAll::Plugin::OTRS::ReplaceCopyright;

use strict;
use warnings;

BEGIN {
    $TidyAll::Plugin::PerlTidy::ReplaceCopyright::VERSION = '0.1';
}
use Moo;
use File::Basename;
use File::Copy qw(copy);
extends 'Code::TidyAll::Plugin';

sub transform_source {
    my ( $Self, $Code ) = @_;

    my $Copy = 'OTRS AG, http://otrs.com/';
    my $StartYear = 2001;

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime(time());
    $Year += 1900;

    my $YearString = "$StartYear-$Year";
    if ($StartYear == $Year) {
        $YearString = $Year;
    }

    my $Output;

    LINE:
    for my $Line ( split(/\n/, $Code) ) {
        if ($Line !~ m{Copyright}smx) {
            $Output .= $Line . "\n";
            next LINE;
        }

        # white list
        # special setting for c.a.p.e. IT and Stefan Schmidt
        if ($Line =~ m{( c\.a\.p\.e\. \s IT | Stefan \s Schmidt )}smx ) {
            $Output .= $Line . "\n";
            next LINE;
        }

        my $OldLine = $Line;

        # special settings for the language directory
        if ($Line !~ m{OTRS}smx && $Code =~ m{ package \s+ Kernel::Language:: }smx ) {
            $Output .= $Line . "\n";
            next LINE;
        }

        # for the commandline help
        # e.g : print "Copyright (c) 2003-2008 OTRS AG, http://www.otrs.com/\n";
        if ($Line !~ m{^\# \s Copyright}smx) {
            if ($Line =~ m{^ (.+?) Copyright \s \( [Cc] \) .+? OTRS \s (AG|GmbH), \s http://otrs.(?:org|com)/}smx) {
                 $Line =~ s{
                     ^ (.+?) Copyright \s \( [Cc] \) .+? OTRS \s (AG|GmbH), \s http://otrs.(?:org|com)/
                 }
                 {$1Copyright (C) $YearString $Copy}smx;

                 if ( $Line ne $OldLine) {
                     print "ReplaceCopyright: Old: $OldLine\n";
                     print "ReplaceCopyright: New: $Line\n";
                 }
            }
            $Output .= $Line . "\n";
            next LINE;
        }

        # check string in the comment line
        if ($Line !~ m{^\# \s Copyright \s \( [Cc] \) \s $YearString \s $Copy$}smx ) {
            $Line = "# Copyright (C) $YearString $Copy";

             if ( $Line ne $OldLine) {
                 print "ReplaceCopyright: Old: $OldLine\n";
                 print "ReplaceCopyright: New: $Line\n";
             }
        }

        $Output .= $Line . "\n";
    }

    return $Output;
}

1;
