# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::Origin;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTRS origins are used
in customized/derived files.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Remove former-origin because it's not needed any more
    $Code =~ s{ ^ [ ]* (?: \# | \/\/ ) [ ]+ (?: \$ )* former-origin: .+? $ \n }{}xmsg;

    my $Origin = '$origin:';

    # Transfers the old origin
    #
    # # $origin: https://github.com/OTRS/ITSMIncidentProblemManagement/blob/74efccbc7821537134b520b508a116afdd489ad4/Kernel/Modules/AgentTicketActionCommon.pm
    #
    # to the new
    #
    # # $origin: ITSMIncidentProblemManagement - 74efccbc7821537134b520b508a116afdd489ad4 - Kernel/Modules/AgentTicketActionCommon.pm
    #
    $Code =~ s{
        ^
        ( [ ]* (?: \# [ ]+  | \/\/ [ ]+ | <Git> ) )
        (?: \$ | ) origin: [ ]+ http (?: s | ) :\/\/ github \. com \/ OTRS \/
        ( [^\/ \n]+ )
        \/ (?: blob\/ | commit\/ |  )
        ( [a-z0-9]+ )
        \/
        ( .+? )
        $
    }{$1$Origin $2 - $3 - $4}xms;

    # Transfers the old origin
    #
    # # $origin: https://git.otrs.com/otrs/ITSMIncidentProblemManagement/blobs/74efccbc7821537134b520b508a116afdd489ad4/Kernel/Modules/AgentTicketActionCommon.pm
    #
    # to the new
    #
    # # $origin: ITSMIncidentProblemManagement - 74efccbc7821537134b520b508a116afdd489ad4 - Kernel/Modules/AgentTicketActionCommon.pm
    #
    $Code =~ s{
        ^
        ( [ ]* (?: \# | \/\/ ) )
        [ ]+ (?: \$ | ) origin: [ ]+ http (?: s | ) :\/\/ git \. otrs \. com \/ otrs \/
        ( [^\/ \n]+ )
        \/ blobs \/
        ( [a-z0-9]+ )
        \/
        ( .+? )
        $
    }{$1 $Origin $2 - $3 - $4}xms;

    # Transfers an CVS OldId
    #
    # # $OldId: AgentTicketEmail.dtl,v 1.142.2.1 2011/09/07 20:53:50 en Exp $
    #
    # to the new origin
    #
    # # $origin: otrs - 0000000000000000000000000000000000000000 - AgentTicketEmail.dtl
    #

    if ( my ($FileString) = $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$OldId: [ ]+ ( [^\n]+? ) ,v [ ]+ [^\n]+ \n }xms ) {

        my $FilePath = $FileString;

        if ( $FileString =~ m{ ^ [^\n]+ \. dtl $ }xms ) {
            $FilePath = 'Kernel/Output/HTML/Standard/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ [^\n]+ \. js $ }xms ) {
            $FilePath = 'var/httpd/htdocs/js/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ (?: Layout | NavBar | NotificationAgent | TicketOverview | TicketMenu | ToolBar | Dashboard ) [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/Output/HTML/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ (?: Agent | Customer | Public ) [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/Modules/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/System/' . $FileString;
        }

        $Code =~ s{
            ^ ( [ ]* (?: \# | \/\/ ) ) [ ]+ \$OldId: [ ]+ [^\n]+? ,v [ ]+ [^\n]+ \n
        }{$1 $Origin otrs - 0000000000000000000000000000000000000000 - $FilePath\n}xms;
    }

    return $Code;
}

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 2, 4 );

    # Check the origin if customization markers are found
    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {

        my $FoundOrigin;
        my $Counter = 0;
        LINE:
        for my $Line ( split /\n/, $Code ) {

            $Counter++;

            last LINE if $Counter > 5;

            next LINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;

            $FoundOrigin = 1;
        }

        die __PACKAGE__ . "\nCustomization markers found but no origin present.\n" if !$FoundOrigin;
    }

    return $Code;
}

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);

    # Check if all files in the Custom directory has an origin
    if ( $Filename =~ m{ \/Custom\/ }xms ) {

        # Check if an origin exist.
        if ( $Code !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms ) {
            die __PACKAGE__ . "\nCustomization markers found but no origin present.\n";
        }
    }

    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    if ( $Filename =~ m{ .* \.css }xmsi ) {

        # Check if a CSS file is overritten in Custom directory.
        if ( $Filename =~ m{ \/Custom\/var\/ }xms ) {

            die __PACKAGE__ . "\n" . <<EOF;
Forbidden to have a CSS file in Custom folder, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if an origin exist.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* ) [ ]+ (?: \$ | \@ ) origin: [ ]+ [^\n]+ $ }xms ) {

            die __PACKAGE__ . "\n" . <<EOF;
Forbidden to have an origin in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if customization markers exists.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* | \/\* ) [ ]+ --- [ ]* $ }xms ) {

            die __PACKAGE__ . "\n" . <<EOF;
Forbidden to have customization markers in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }
    }

    return;
}

1;
