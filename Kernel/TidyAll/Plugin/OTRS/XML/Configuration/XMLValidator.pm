
# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::XMLValidator;

use strict;
use warnings;

use File::Basename;
use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my @InvalidSettings;
    my $LineNumber = 0;

    my @ConfigItems = split( "</ConfigItem>\n", $Code );

    for my $ConfigItem (@ConfigItems) {
        my @Lines = split( "\n", $ConfigItem );

        my $Type = '';
        my @ItemKeys;

        LINE:
        for my $Line (@Lines) {

            # Increment line number
            $LineNumber++;

            my $Invalid;

            if ( $Line =~ m{Name="Frontend::Module}gsmx ) {
                $Type = "Frontend";
            }
            elsif ( $Line =~ m{Name="Loader::Module}gsmx ) {
                $Type = "Loader";
            }

            if ( $Type eq 'Frontend' ) {

                # Check if Item tag is open, but not closed in same line
                if (
                    $Line !~ m{</Item>$}gsmx
                    && $Line =~ m{<Item\s+Key="(.*?)"}gsmx
                    )
                {
                    push @ItemKeys, $1;
                    next LINE;
                }
                elsif ( $Line =~ m{^\s*</Item>$}gsmx ) {
                    pop @ItemKeys;
                }
                elsif (
                    $Line =~ m{^\s*<Item>$}gsmx
                    && scalar @ItemKeys
                    )
                {
                    # If there is only Item without Key attribute,
                    # take it as last item.
                    push @ItemKeys, $ItemKeys[-1];
                }

                my $LastItemKey;
                if ( scalar @ItemKeys ) {
                    $LastItemKey = $ItemKeys[-1];
                }

                $Invalid = $Self->_ValidateFrontend(
                    String      => $Line,
                    LineNumber  => $LineNumber,
                    LastItemKey => $LastItemKey,
                );
            }
            elsif ( $Type eq 'Loader' ) {
                $Invalid = $Self->_ValidateLoader(
                    String     => $Line,
                    LineNumber => $LineNumber,
                );
            }

            # check if Item tag is opened in this line
            if ( $Line =~ m{<Item} ) {

                $Invalid = $Self->_ValidateItem(
                    String     => $Line,
                    LineNumber => $LineNumber,
                );
            }

            if ($Invalid) {
                push @InvalidSettings, $Invalid;
            }
        }
    }

    my $ErrorMessage = "";

    if (@InvalidSettings) {
        $ErrorMessage .= join( "\n", @InvalidSettings ) . "\n";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

sub _ValidateItem {
    my ( $Self, %Param ) = @_;

    # Check needed params
    for my $Needed (qw(String LineNumber)) {
        return if !$Param{$Needed};
    }

    my @ValidItemAttributes = qw(String File Textarea Checkbox Select Entity PerlModule Date DateTime TimeZone
        VacationDays VacationDaysOneTime WorkingHours Key Translatable SelectedID);

    my %Pairs = $Self->_GetKeyValuePairs( String => $Param{String} );

    PAIR:
    for my $Attribute ( sort keys %Pairs ) {
        if (
            $Attribute !~ m{^Value.*?$}gsmx    # Check if starts with Value
            && !grep { $Attribute eq $_ } @ValidItemAttributes    # Check if matches whitelisted attributes
            )
        {
            return "$Attribute is not allowed at #$Param{LineNumber} - $Param{String}";
        }
    }

    return;
}

sub _ValidateFrontend {
    my ( $Self, %Param ) = @_;

    # Check needed params
    for my $Needed (qw(String LineNumber)) {
        return if !$Param{$Needed};
    }

    my @ValidKeyValues;

    my $Value;
    if ( $Param{String} =~ m{<Item\s+Key="(.*?)"}gsmx ) {
        $Value = $1;
    }

    return if !$Value;

    # Define which values are allowed for Key attribute
    if ( !$Param{LastItemKey} ) {
        @ValidKeyValues = qw(GroupRo Group Description Title NavBarName);
    }
    elsif ( $Param{LastItemKey} eq 'NavBar' ) {
        @ValidKeyValues = qw(GroupRo Group Description Name Link LinkOption NavBar
            Type Block AccessKey Prio);
    }
    elsif ( $Param{LastItemKey} eq 'NavBarModule' ) {
        @ValidKeyValues = qw(GroupRo Group Description Name Module Block Prio);
    }

    if (@ValidKeyValues) {
        if (
            !grep { $Value eq $_ } @ValidKeyValues    # Check if matches whitelisted key values
            )
        {
            my $Line = $Param{String};
            $Line =~ s{^\s*(.*?)$}{$1}gsmx;

            return "$Value is not allowed at #$Param{LineNumber} - $Line";
        }
    }

    return;
}

sub _ValidateLoader {
    my ( $Self, %Param ) = @_;

    # Check needed params
    for my $Needed (qw(String LineNumber)) {
        return if !$Param{$Needed};
    }

    my @ValidKeyValues = qw(CSS JavaScript);

    my $Value;
    if ( $Param{String} =~ m{<Item\s+Key="(.*?)"}gsmx ) {
        $Value = $1;
    }

    return if !$Value;

    if (
        !grep { $Value eq $_ } @ValidKeyValues    # Check if matches whitelisted key values
        )
    {
        my $Line = $Param{String};
        $Line =~ s{^\s*(.*?)$}{$1}gsmx;

        return "$Value is not allowed at #$Param{LineNumber} - $Line";
    }

    return;
}

sub _GetKeyValuePairs {
    my ( $Self, %Param ) = @_;

    return if !$Param{String};

    # Extract Item tag
    $Param{String} =~ m{^\s+(<Item\s+.*?>)}gsmx;
    my $Item = $1;

    return if !$Item;

    # Extract attributes part
    my $Attributes;
    if ( $Item =~ m{^\s*<Item\s+(.*?)>}gsmx ) {
        $Attributes = $1;
    }

    return if !$Attributes;

    # Each item contains key=value pair
    my @Pairs = split( "\" ", $Attributes );

    my %Result;

    for my $Pair (@Pairs) {
        my $Key;

        # Extract Attribute and Value
        if ( $Pair =~ m{^\s*(.*?)="(.*?)$}gsmx ) {
            $Key = $1;
            $Result{$Key} = $2;
        }

        # Remove " on end of the string, if exist
        if ( $Result{$Key} =~ m{^(.*?)"$} ) {
            $Result{$Key} = $1;
        }
    }

    return %Result;
}

1;
