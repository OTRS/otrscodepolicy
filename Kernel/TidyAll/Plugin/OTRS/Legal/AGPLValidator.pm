# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Legal::AGPLValidator;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTRS::Legal::AGPLValidator)

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     the enclosed file COPYING for license information (GPL). If you
    #
    # Replacement:
    #     the enclosed file COPYING for license information (AGPL). If you
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ |  ) ) the [ \s \w ]+ COPYING [ \s \w ]+ \(GPL\) \. [ \s \w ]+ you
    }{$1the enclosed file COPYING for license information (AGPL). If you}xmsg;

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
    #     did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
    #     did not receive this file, see L<http://www.gnu.org/licenses/gpl-2.0.txt>.
    #     did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
    #
    # Replacement:
    #     did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ ) ) did [ \s \w ]+ \, \s+ see \s+ (?: L< |  ) http:\/\/www\.gnu\.org\/licenses\/ (?: a |  ) gpl (?: -2\.0 |  ) \.txt (?: > |  ) \.
    }{$1did not receive this file, see http://www.gnu.org/licenses/agpl.txt.}xmsg;

    # Replace this license line in .pm .pl (perldoc) files.
    #
    # Original:
    #     did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
    #     did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
    #     did not receive this file, see L<http://www.gnu.org/licenses/gpl-2.0.txt>.
    #     did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
    #     did not receive this file, see <http://www.gnu.org/licenses/agpl.txt>.
    #
    # Replacement:
    #     did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
    #
    $Code =~ s{
        ^ did [ \s \w ]+ \, \s+ see \s+ (?: L< | < |  ) http:\/\/www\.gnu\.org\/licenses\/ (?: a |  ) gpl (?: -2\.0 |  ) \.txt (?: > | > |  ) \.
    }{did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.}xmsg;

    # Replace this license line in .pm .pl .tt and .js files.
    #
    # Original:
    #     This software is part of the OTRS project (L<http://otrs.org/>).
    #     This software is part of the OTRS project (L<http://otrs.com/>).
    #     This software is part of the OTRS project (<http://otrs.com/>).
    #
    # Replacement:
    #     This software is part of the OTRS project (http://otrs.org/).
    #
    $Code =~ s{
        ^ ( (?: \# \s+ | \/\/ \s+ ) ) This \s+ software \s+ is \s+ part \s+ of \s+ the \s+ OTRS \s+ project \s+ \( (?: L< | < ) http:\/\/otrs\. (?: org | com ) \/>\) \.
    }{$1This software is part of the OTRS project (http://otrs.org/).}xmsg;

    # Replace this license line in .pm .pl (perldoc) files.
    #
    # Original:
    #     This software is part of the OTRS project (http://otrs.org/).
    #     This software is part of the OTRS project (http://otrs.com/).
    #     This software is part of the OTRS project (<http://otrs.org/>).
    #
    # Replacement:
    #     This software is part of the OTRS project (L<http://otrs.org/>).
    #
    $Code =~ s{
        ^ This \s+ software \s+ is \s+ part \s+ of \s+ the \s+ OTRS \s+ project \s+ \( (?: < |  ) http:\/\/otrs\. (?: org | com ) \/ (?: > |  ) \) \.
    }{This software is part of the OTRS project (L<http://otrs.org/>).}xmsg;

    # Define old and new FSF FSF Mailing Addresses.
    my $OldFSFAddress = '59 \s+ Temple \s+ Place, \s+ Suite \s+ 330, \s+ Boston, \s+ MA \s+ 02111-1307 \s+ USA';
    my $NewFSFAddress = '51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA';

    # Replace FSF Mailing Address.
    if ( $Code =~ s{$OldFSFAddress}{$NewFSFAddress}xms ) {
        print "NOTICE: _AGPL3LicenseCheck() updated the FSF Mailing Address\n";
    }

    my $AGPLLong = _AGPLLong();

    # Replace the license header in .pl files.
    $Code =~ s{
        \# \s+ -- \n
        \# \s+ This \s+ program \s+ is \s+ free \s+ software; \s+ [ \s \w \, \. \; \# \/ \( \) ]+
        51 \s+ Franklin \s+ St, \s+ Fifth \s+ Floor, \s+ Boston, \s+ MA \s+ 02110-1301 \s+ USA .*?
        \# \s+ -- \n
    }{$AGPLLong}xmsg;

    return $Code;
}

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);

    my ($Filetype) = $Filename =~ m{ .* \. ( .+ ) }xmsi;

    # Check a javascript license header.
    if ( lc $Filetype eq 'js' ) {

        my $AGPLJavaScript = _AGPLJavaScript();

        die __PACKAGE__ . "\nFound no valid .js license header!" if $Code !~ m{\Q$AGPLJavaScript\E};
    }

    # Check a perl script license header.
    elsif ( lc $Filetype eq 'pl' || lc $Filetype eq 'psgi' ) {

        my $AGPLLong = _AGPLLong();

        die __PACKAGE__ . "\nFound no valid .pl license header!" if $Code !~ m{\Q$AGPLLong\E};
    }

    # Check default license header.
    else {

        my $AGPLShort = _AGPLShort();

        die __PACKAGE__ . "\nFound no valid license header!" if $Code !~ m{\Q$AGPLShort\E};
    }

    # Check perldoc license header.
    if ( lc $Filetype eq 'pl' || lc $Filetype eq 'pm' ) {

        if ( $Code =~ m{ =head1 \s+ TERMS \s+ AND \s+ CONDITIONS \n+ This \s+ software \s+ is \s+ part }smx ) {

            my $AGPLPerldoc = _AGPLPerldoc();

            die __PACKAGE__ . "\nFound no valid perldoc license header!" if $Code !~ m{\Q$AGPLPerldoc\E};
        }
    }

    # Check if there is aother strange license content.
    if ( $Code =~ m{(^ [^\n]* (?: \(GPL\) | /gpl ) [^\n]* $)}smx ) {
        die __PACKAGE__ . "\nThere is strange license wording!\nLine: $1";
    }
}

sub _AGPLLong {
    return <<'END_AGPLLONG';
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --
END_AGPLLONG

}

sub _AGPLShort {
    return <<'END_AGPLSHORT';
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
END_AGPLSHORT
}

sub _AGPLJavaScript {
    return <<'END_AGPLJAVASCRIPT';
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --
END_AGPLJAVASCRIPT
}

sub _AGPLPerldoc {
    return <<'END_AGPLPERLDOC';
=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
END_AGPLPERLDOC

}

1;
