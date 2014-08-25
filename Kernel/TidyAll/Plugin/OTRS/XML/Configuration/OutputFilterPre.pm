# --
# TidyAll/Plugin/OTRS/XML/Configuration/OutputFilterPre.pm - code quality plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Configuration::OutputFilterPre;

use strict;
use warnings;

use File::Basename;
use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    my @InvalidSettings;

    $Code =~ s{
        (<ConfigItem\s*Name="Frontend::Output::FilterElementPre.*?>)
        (.*?)
        </ConfigItem>

    }{
        my $StartTag = $1;
        my $TagContent = $2;

        if ($TagContent =~ m{ALL}smx) {
            push @InvalidSettings, $StartTag;
        }

    }smxge;

    my $ErrorMessage;

    if (@InvalidSettings) {
        $ErrorMessage
            .= "Don't create pre output filters that operate on ALL templates as they prohibit the templates from being cached.\n";
        $ErrorMessage
            .= "This can lead to serious performance issues. Please only use pre filters when absolutely neccessary.\n";
        $ErrorMessage .= "Wrong settings found: " . join( ', ', @InvalidSettings ) . "\n";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
