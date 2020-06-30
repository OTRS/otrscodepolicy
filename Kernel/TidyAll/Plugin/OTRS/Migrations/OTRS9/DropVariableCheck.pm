# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS9::DropVariableCheck;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTRS::Base';

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 9, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 10, 0 );

    return $Code if $Code !~ m{^use\s+Kernel::System::VariableCheck}smx;

    my %FunctionMap = (
        'IsArrayRefWithData' => 'is_ArrayRefWithData',
        'IsHashRefWithData'  => 'is_HashRefWithData',
        'IsInteger'          => 'is_Int',
        'IsIPv4Address'      => 'is_IPv4',
        'IsIPv6Address'      => 'is_IPv6',
        'IsMD5Sum'           => 'is_MD5',
        'IsNumber'           => 'is_Num',
        'IsPositiveInteger'  => 'is_PositiveInt',
        'IsString'           => 'is_Str',
        'IsStringWithData'   => 'is_StrWithData',
        'DataIsDifferent'    => 'DataIsDifferent',
    );

    my $Replaced;

    for my $LegacyFunction ( sort keys %FunctionMap ) {

        # Replace fully qualified calls like K:S:VariableCheck::DataIsDifferent( ... ).
        $Replaced += $Code
            =~ s{Kernel::System::VariableCheck::$LegacyFunction\(}{Kernel::System::DataTypes::$FunctionMap{$LegacyFunction}(}smxg;

        # Replace imported calls like IsHashRefWithData( ... ).
        $Replaced += $Code =~ s{$LegacyFunction\(}{$FunctionMap{$LegacyFunction}(}smxg;
    }

    if ( $Code =~ m{^use\s+Kernel::System::DataTypes} || !$Replaced ) {
        $Code =~ s{^use\s+Kernel::System::VariableCheck.*?\n}{}smxg;
    }
    else {
        $Code =~ s{^use\s+Kernel::System::VariableCheck.*?$}{use Kernel::System::DataTypes;}smxg;
    }

    return $Code;
}

1;
