# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Common::CustomizationMarkers;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTRS::Common::Origin)

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTRS customization markers are used
to mark changed lines in customized/derived files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    # Find wrong customization markers without space or with 4 hyphens and correct them
    #
    #   #---
    #
    #   to
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]* ( (?: \# | \/\/ ) ) [ ]* -{3,4} [ ]* $ }{$1 ---}xmsg;

    # Find wrong customization markers in JS files an correct them
    #
    #   /***/
    #
    #   to
    #
    #   // ---
    #
    $Code =~ s{ ^ [ ]* \/ [ ]* \*{2,3} [ ]* \/ [ ]* $ }{// ---}xmsg;

    # Find wrong comments and correct them
    #
    #   # --------------------
    #
    #   or
    #
    #   #-----------------------------------
    #
    #   to
    #
    #   #
    #
    $Code =~ s{ ^ \n ^ [ ]* (?: \# | \/\/ ) [ ]* -{5,50} [ ]* $ \n ^ \n }{\n}xmsg;
    $Code =~ s{ ^ ( [ ]* (?: \# | \/\/ ) ) [ ]* -{5,50} [ ]* $ }{$1}xmsg;

    # Find somesthing like that and remove the leading spaces
    #
    #   # ---
    #   # OTRSXyZ - Here a comment.
    #   # ---
    #
    #   or
    #
    #   # ---
    #   # OTRSXyZ
    #   # ---
    #   # my $Subject = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSubjectClean();
    #
    $Code =~ s{
        (
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ --- [ ]* $ \n
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ [^ ]+ (?: [ ]+ - [^\n]+ | ) $ \n
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ --- [ ]* $ \n
            (?: ^ [ ]+ (?: \# | \/\/ ) [^\n]* $ \n )*
        )
    }{
        my $String = $1;
        $String =~ s{ ^ [ ]+ }{}xmsg;
        $String;
    }xmsge;

    # Find wrong customization markers in JS files an correct them
    #
    #   /**
    #   * OTRSXyZ - Here a comment.
    #   **/
    #
    #   or
    #
    #   /***
    #   * OTRSXyZ
    #   ***/
    #
    #   to
    #
    #   // ---
    #   // OTRSXyZ
    #   // ---
    #
    $Code =~ s{
        ^ [ ]* \/ [ ]* \*{2,3} [ ]* $ \n
        ^ [ ]* \*{1,3} [ ]+ ( [^ ]+ (?: [ ]+ - [^\n]+ | ) ) $ \n
        ^ [ ]* \*{2,3} [ ]* \/ [ ]* $ \n
    }{$Self->_CustomizationMarker($1)}xmsge;

    # Find somesthing like that and remove the leading spaces
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]+ ( (?: \# | \/\/ ) ) [ ]+ --- [ ]* $ }{$1 ---}xmsg;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my ( $Counter, $Flag, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {

        $Counter++;

        # Allow ## no critic and ## use critic
        next LINE if $Line =~ m{^ \s* \#\# \s+ (?:no|use) \s+ critic}xms;

        # Allow ## nofilter
        next LINE if $Line =~ m{^ \s* \#\# \s+ nofilter }xms;

        if ( $Line =~ /^[^#]/ && $Counter < 24 ) {
            $Flag = 1;
        }
        if ( $Line =~ /^ *# --$/ && ( $Counter > 23 || ( $Counter > 10 && $Flag ) ) ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ [ ]* - [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ -{1,} [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ [ ]* -{4,40} [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ /^ *#+ *[\*\+]+$/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ ){3,} }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Please remove or replace wrong Separators like '# --', valid only: # --- (for customizing otrs files).
$ErrorMessage
EOF
    }

    return $Code;
}

sub _CustomizationMarker {
    my ( $Self, $Module ) = @_;

    return <<"END_CUSTOMMARKER";
// ---
// $Module
// ---
END_CUSTOMMARKER
}

1;
