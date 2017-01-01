# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::CustomizationMarkers;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTRS customization markers are used
to mark changed lines in customized/derived files.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    # Find wron customization markers without space or with 4 hyphens and correct them
    #
    #   #---
    #
    #   to
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]* ( (?: \# | \/\/ ) ) [ ]* -{3,4} [ ]* $ }{$1 ---}xmsg;

    # Find wron comments and correct them
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

    # Find somesthing like that and remove the leading spaces
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]+ ( (?: \# | \/\/ ) ) [ ]+ --- [ ]* $ }{$1 ---}xmsg;

    return $Code;
}

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    #    # Check the origin if customization markers are found
    #    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {
    #
    #        my $FoundOrigin;
    #        my $Counter = 0;
    #        LINE:
    #        for my $Line ( split /\n/, $Code ) {
    #
    #            $Counter++;
    #
    #            last LINE if $Counter > 5;
    #
    #            next LINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;
    #
    #            $FoundOrigin = 1;
    #        }
    #
    #        die __PACKAGE__ . "\nCustomization markers found but no origin present.\n" if !$FoundOrigin;
    #    }

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

1;
