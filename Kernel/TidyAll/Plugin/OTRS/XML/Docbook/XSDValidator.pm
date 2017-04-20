# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Docbook::XSDValidator;

use strict;
use warnings;

use File::Basename;
use Capture::Tiny qw(capture_merged);
use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # convert format attribute content in imagedata tag to upper case
    #    e.g. from format="png" to format="PNG"
    $Code =~ s{(<imagedata [^>]+ format=")(.+?)(" [^>]+ >)}
        {
            my $Start  = $1;
            my $Format = $2;
            my $End    = $3;
            if ($Format ne 'linespecific') {
                $Format = uc $Format;
            }
            my $Result = $Start . $Format . $End;
        }msxge;

    return $Code;
}

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 1 );

    # read the file as an array
    open FH, "$Filename" or die $!;    ## no critic
    my @FileLines = <FH>;
    close FH;

    my $Version;

    # get the DocBook version from the DocType e.g. 4.4
    if ( $FileLines[1] =~ m{DTD [ ] DocBook [ ] XML [ ] V(\d\.\d)//}msxi ) {
        $Version = $1;
    }
    return if !$Version;

    # check if we have an XSD available for the detected version:
    my %AvailableVersions = (
        '4.2' => 1,
        '4.3' => 1,
        '4.4' => 1,
        '4.5' => 1,
    );
    if ( !$AvailableVersions{$Version} ) {
        print STDERR "No DocBook XSD available for version $Version\n";
        return;
    }

    # convert the version to a directory safe string e.g. 4_4
    $Version =~ s{\.}{_};

    # generate the XMLLint command based on the version of the DocBook file
    my $XSDFile = dirname(__FILE__) . '/../../StaticFiles/XSD/Docbook/' . $Version . '/docbook.xsd';
    my $CMD     = "xmllint --noout --nonet --nowarning --schema $XSDFile";

    my $Command = sprintf( "%s %s %s", $CMD, $Self->argv(), $Filename );
    my ( $Output, @Result ) = capture_merged { system($Command) };

    # if execution failed, warn about installing package
    if ( $Result[0] == -1 ) {
        print STDERR "'xmllint' is not installed.\n";
        print STDERR
            "You can install this using 'apt-get install libxml2-utils' package on Debian-based systems.\n\n";
    }

    if ( @Result && $Result[0] ) {
        die __PACKAGE__ . "\n$Output\n";    # non-zero exit code
    }
}

1;
