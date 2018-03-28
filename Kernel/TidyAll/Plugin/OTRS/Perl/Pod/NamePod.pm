# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Pod::NamePod;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Updated = 0;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $Line =~ s{^\s* ([A-Za-z0-9:/\.]+)}{$PackageName}smx;
                $Updated = 1;
            }
            last LINE;
        }
    }

    if ($Updated) {
        $Code = join "\n", @CodeLines;
        $Code .= "\n";
    }

    return $Code;
}

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Counter = 0;
    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        $Counter++;

        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $ErrorMessage = "PackageName $PackageNamePod does not match package $PackageName\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            last LINE;
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }

    return;
}

1;
