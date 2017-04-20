# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Pod::FunctionPod;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    # temporarily disable
    # TODO CHECK
    #return;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $FunctionNameInPod = '';
    my $FunctionLineInPod = '';
    my $FunctionCallInPod = '';
    my $Counter           = 0;

    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ m{^=head2 \s+ ([A-Za-z0-9]+) (\(\))? \s* $}smx ) {

            my $FunctionName = $1;
            my $IsFunctionPod = $2 ? 1 : 0;

            if ($IsFunctionPod) {
                $FunctionNameInPod = $FunctionName;
                $FunctionLineInPod = $Line;
                chomp($FunctionLineInPod);
            }
            elsif ( $Code =~ m{sub $FunctionName} ) {
                $ErrorMessage
                    .= "Item without function (near Line $Counter), the line should look like '=item functionname()'\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /->(.+?)\(/ && !$FunctionCallInPod ) {
            $FunctionCallInPod = $1;
            $FunctionCallInPod =~ s/ //;

            if ( $Line =~ /\$Self->/ ) {
                $ErrorMessage .= "Don't use \$Self in perldoc\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            elsif ( $FunctionNameInPod ne $FunctionCallInPod ) {
                if ( $FunctionNameInPod ne 'new' || ( $FunctionCallInPod ne 'Get' && $FunctionCallInPod ne 'Create' ) )
                {
                    my $DescriptionLine = $Line;
                    chomp($DescriptionLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $DescriptionLine\n";
                }
            }
            if ( $FunctionNameInPod && $Line !~ /\$[A-Za-z0-9:]+->(.+?)\(/ && $FunctionNameInPod ne 'new' ) {
                $ErrorMessage .= "The function syntax is not correct!\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /sub/ ) {
            if ( $Line =~ /sub (.+) \{/ ) {
                my $FunctionSub = $1;
                $FunctionSub =~ s/ //;
                my $SubLine = $Line;

                if ( $FunctionSub ne $FunctionNameInPod ) {
                    chomp($SubLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $SubLine \n";
                }
            }
            $FunctionNameInPod = '';
            $FunctionCallInPod = '';
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }

    return;
}

1;
