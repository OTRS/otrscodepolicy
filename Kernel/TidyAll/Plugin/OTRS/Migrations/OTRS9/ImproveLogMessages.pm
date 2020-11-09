# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS9::ImproveLogMessages;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 9, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 10, 0 );

    my $Condition = qr{
        (?<Condition>^ \s+ if \s+ \( [^\n]+ \n? (?: \s+ \{ )? \n+)
    }smx;

    my $LogCall = qr{
        (?<LogCallPrefix>^ \s+     (?:\$LogObject|\$Kernel::OM->Get\('Kernel::System::Log'\)))->Log\(\n
    }smx;

    my $PriorityArgument = qr{
        (^ \s+) Priority \s+ => \s+ ['"]error['"],\n
    }smx;

    my $MessageArgument = qr{
        (?<ArgumentIndentation>^ \s+)
        Message  \s+ => \s+ ['"]
        (?:
            (?:Need|Got[ ]no) \s (?<ErrorParameterName1>[^ .!]+) (?:[ ]or[ ](?<ErrorParameterName2>[^ .!]+))? ([ ]in[ ]Data)? [.!]* ['"] ,?\n
            |
            (?<ErrorParameterName1>[^ .!]+) [ ]is[ ] (?:missing[ ]or[ ])? invalid [.!]* ['"] ,?\n
        )
    }smx;

    $Code =~ s{
        $Condition
        $LogCall
        (?:
            (?:
                $PriorityArgument
                $MessageArgument
            )
            |
            (?:
                $MessageArgument
                $PriorityArgument
            )
        )
    }{
        my %Matches = %+;
        my $Result = "$Matches{Condition}$Matches{LogCallPrefix}->Error(\n";
        if ($Matches{ErrorParameterName2}) {
            $Result   .= "$Matches{ArgumentIndentation}\"One of the parameters '$Matches{ErrorParameterName1}' or '$Matches{ErrorParameterName2}' is required, but none was provided.\",\n";
        }
        elsif ($Matches{Condition} =~ m{ !\s*\$ | !\s*defined }smx && $Matches{Condition} =~ m{ if \s* \( \s* ! }smx) {
            $Result   .= "$Matches{ArgumentIndentation}\"The required parameter '$Matches{ErrorParameterName1}' is missing.\",\n";
        }
        else {
            $Result   .= "$Matches{ArgumentIndentation}\"The parameter '$Matches{ErrorParameterName1}' is invalid.\",\n";
        }
        if ( index( $Matches{Condition}, "\$Param\{" ) > 0 ) {
            $Result   .= "$Matches{ArgumentIndentation}Context => \\\%Param,\n";
        }
        $Result;
    }esmxg;

    return $Code;
}

1;
