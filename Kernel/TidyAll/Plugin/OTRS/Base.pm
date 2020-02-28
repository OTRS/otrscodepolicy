# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Base;

use strict;
use warnings;

use Encode();
use TidyAll::OTRS;

use parent qw(Code::TidyAll::Plugin);

sub IsPluginDisabled {
    my ( $Self, %Param ) = @_;

    my $PluginPackage = ref $Self;

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

sub DieWithError {
    my ( $Self, $Error ) = @_;

    chomp $Error;

    die _Color( 'yellow', ref($Self) ) . "\n" . _Color( 'red', $Error ) . "\n";
}

=head2 _Color()

This will color the given text (see Term::ANSIColor::color()) if ANSI output is available and active, otherwise the text
stays unchanged.

    my $PossiblyColoredText = _Color('green', $Text);

=cut

sub _Color {
    my ( $Color, $Text ) = @_;

    return $Text if $ENV{OTRSCODEPOLICY_NOCOLOR};

    return Term::ANSIColor::color($Color) . $Text . Term::ANSIColor::color('reset');
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
