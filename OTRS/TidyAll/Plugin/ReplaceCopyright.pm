package OTRS::TidyAll::Plugin::ReplaceCopyright;
BEGIN {
    $OTRS::TidyAll::Plugin::PerlTidy::ReplaceCopyright::VERSION = '0.1';
    $^I = '.tmp';
}
use Moo;
use File::Basename;
use File::Copy qw(copy);
extends 'Code::TidyAll::Plugin';

sub transform_file {
    my ( $Self, $File ) = @_;

	my @Original_Filepath = keys $Self->{tidyall}{plugins_for_path};

	my( $Filename, $Directory ) = fileparse( $Original_Filepath[0] );

	# config
    my $StartYear = 0;
    my $Copy = '';

    if ( $Directory =~ m{\/cvs\/} ) {
        $Copy = 'OTRS AG, http://otrs.org/';
        $StartYear = 2001;
    }
    else {
        $Copy = 'OTRS AG, http://otrs.com/';
        $StartYear = 2003;
    }

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime(time());
    $Year += 1900;

    my $YearString = "$StartYear-$Year";
    if ($StartYear == $Year) {
        $YearString = $Year;
    }

    # not for cpan files
    return 1 if $Directory =~ /Kernel\/cpan-lib/;

    copy($File, "$File.tmp");
    open my $In, '<', $File           or die "FILTER: Can't open $File: $!\n";
    open my $Out, '>', "$File.$$.tmp" or die "FILTER: Can't write $File.tmp: $!\n";

    IN:
    while ( my $Line = <$In> ) {
        if ($Line !~ m{Copyright}smx) {
            print $Out $Line;
            next IN;
        }

        # white list
        # special setting for c.a.p.e. IT and Stefan Schmidt
        if ($Line =~ m{( c\.a\.p\.e\. \s IT | Stefan \s Schmidt )}smx ) {
            print $Out $Line;
            next IN;
        }

        # special settings for the language directory
        if ($Line !~ m{OTRS}smx && $Directory =~ m{Kernel\/Language} ) {
            print $Out $Line;
            next IN;
        }

        # for the commandline help
        # e.g : print "Copyright (c) 2003-2008 OTRS AG, http://www.otrs.com/\n";
        if ($Line !~ m{^\# \s Copyright}smx) {
            if ($Line =~ m{^ (.+?) Copyright \s \( [Cc] \) .+? OTRS \s (AG|GmbH) }smx) {
                 print "NOTICE: Old: $Line";
                 $Line =~ s{^ (.+?) Copyright \s \( [Cc] \) .+? OTRS \s (AG|GmbH) }{$1Copyright (C) $YearString OTRS AG}smx;
                 print "NOTICE: New: $Line";
            }
            print $Out $Line;
            next IN;
        }

        # check string in the comment line
        if ($Line !~ m{^\# \s Copyright \s \( [Cc] \) \s $YearString \s $Copy$}smx ) {
            print "NOTICE: Old: $Line";
            print "NOTICE: New: # Copyright (C) $YearString $Copy\n";
            $Line = "# Copyright (C) $YearString $Copy\n";
        }

        print $Out $Line;
    }

    close $Out;
    close $In;
    unlink $File or die "FILTER: Can't unlink: $!\n";
    rename "$File.$$.tmp", $File or die "FILTER: Can't rename: $!\n";

    print "NOTICE: _ReplaceCopyright() ok\n";
    return 1;
}

1;
