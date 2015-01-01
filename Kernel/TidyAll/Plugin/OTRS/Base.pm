# --
# TidyAll/Plugin/OTRS/Base.pm - code quality plugin base class
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Base;

use strict;
use warnings;

use Scalar::Util;
use TidyAll::OTRS;
use Pod::Strip;

use base qw(Code::TidyAll::Plugin);

sub IsPluginDisabled {
    my ( $Self, %Param ) = @_;

    my $PluginPackage = Scalar::Util::blessed($Self);

    if ( !defined $Param{Code} && !defined $Param{Filename} ) {
        print STDERR "Need Code or Filename!\n";
        die;
    }

    my $Code = defined $Param{Code} ? $Param{Code} : $Self->_GetFileContents( $Param{Filename} );

    if ( $Code =~ m{nofilter\([^()]*\Q$PluginPackage\E[^()]*\)}ismx ) {
        return 1;
    }

    return;
}

sub IsFrameworkVersionLessThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::OTRS::FrameworkVersionMajor) {
        return 1 if $TidyAll::OTRS::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 0 if $TidyAll::OTRS::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 1 if $TidyAll::OTRS::FrameworkVersionMinor < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

sub IsThirdpartyModule {
    my ($Self) = @_;

    return $TidyAll::OTRS::ThirdpartyModule ? 1 : 0;
}

#Process Perl code and replace all Pod sections with comments.

sub StripPod {
    my ( $Self, %Param ) = @_;

    my $PodStrip = Pod::Strip->new();
    $PodStrip->replace_with_comments(1);
    my $Code;
    $PodStrip->output_string( \$Code );
    $PodStrip->parse_string_document( $Param{Code} );
    return $Code;
}

sub _GetFileContents {
    my ( $Self, $Filename ) = @_;

    my $FileHandle;
    if ( !open $FileHandle, '<', $Filename ) {    ## no critic
        print STDERR "Can't open $Filename\n";
        die;
    }

    my $Content = do { local $/; <$FileHandle> };
    close $FileHandle;

    return $Content;
}

1;
