# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PodSpelling;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    # temporarily disable
    # TODO CHECK
    return;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my $FunctionItem        = '';
    my $FunctionSub         = '';
    my $ItemLine            = '';
    my $SubLine             = '';
    my $DescriptionLine     = '';
    my $FunctionDescription = '';
    my $Counter             = 0;

    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ m{^=item}smx ) {
            if ( $Line =~ /=item (.+)\(\)/ ) {
                $FunctionItem = $1;
                $FunctionItem =~ s/ //;
                $ItemLine = $Line;
                chomp($ItemLine);
            }
            else {
                $ErrorMessage
                    .= "Item without function (near Line $Counter), the line should look like '=item functionname()'\n";
                $ErrorMessage .= "Line $Counter: $Line";
            }
        }
        if ( $FunctionItem && $Line =~ /->(.+?)\(/ && !$FunctionDescription ) {
            $FunctionDescription = $1;
            $FunctionDescription =~ s/ //;

            if ( $Line =~ /\$Self->/ ) {
                chomp($DescriptionLine);
                $ErrorMessage .= "Don't use \$Self in perldoc\n";
                $ErrorMessage .= "Line $Counter: $Line";
            }
            elsif ( $FunctionItem ne $FunctionDescription ) {
                $DescriptionLine = $Line;
                chomp($DescriptionLine);
                $ErrorMessage .= "$ItemLine <-> $DescriptionLine \n";
            }
            if ( $FunctionItem && $Line !~ /\$[A-Za-z0-9]+->(.+?)\(/ && $FunctionItem ne 'new' ) {
                $ErrorMessage .= "The function syntax is not correct!\n";
                $ErrorMessage .= "Line $Counter: $Line";
            }
        }
        if ( $FunctionItem && $Line =~ /sub/ ) {
            if ( $Line =~ /sub (.+) \{/ ) {
                $FunctionSub = $1;
                $FunctionSub =~ s/ //;
                $SubLine = $Line;

                if ( $FunctionSub ne $FunctionItem ) {
                    chomp($SubLine);
                    $ErrorMessage .= "$ItemLine <-> $SubLine \n";
                }
            }
            $FunctionItem        = '';
            $FunctionDescription = '';
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }

    return;
}

1;
