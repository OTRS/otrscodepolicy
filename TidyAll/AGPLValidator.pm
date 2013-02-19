package Code::TidyAll::Plugin::AGPLValidator;
BEGIN {
  $Code::TidyAll::Plugin::PerlTidy::AGPLValidator::VERSION = '0.1';
}
use Moo;
extends 'Code::TidyAll::Plugin';

sub transform_source {
    my ( $Self, $Code ) = @_;

	my $AGPLLong      = _AGPLLong();
    my $GPLLongRegExp = <<'    END_REGEXP';
        \# \s -- \n
        \# \s This \s program \s is \s free \s software
        .*?
        \# \s+ Foundation, \s+ Inc., \s+ 51 \s+ Franklin \s+ St, \s+ Fifth \s+ Floor, \s+ Boston, \s+ MA \s+ 02111-1301 \s+ USA \n
        \# \s -- \n
    END_REGEXP

    my $AGPLShort      = _AGPLShort();
    my $GPLShortRegExp = <<'    END_REGEXP';
        \# \s -- \n
        \# \s This \s software \s comes \s with \s ABSOLUTELY \s NO \s WARRANTY.
        .*?
        \# \s+ did \s+ not \s+ receive \s+ this \s+ file, \s+ see  \s+ http:\/\/www\.gnu\.org\/licenses\/gpl (?: -2\.0 |  ) \.txt\. \n
        \# \s -- \n
    END_REGEXP

    # check if there is a valid licence header!
    if (
        $Code !~ m{$GPLLongRegExp}smx
        && $Code !~ m{$GPLShortRegExp}smx
        && $Code !~ m{\Q$AGPLShort\E}
        && $Code !~ m{\Q$AGPLLong\E}
        )
    {
        die('WARNING: AGPL3LicenseCheck - Found no valid licence header!');
    }
	
	my $Flag = 0;
    # The following code replace the license GPL2 with AGPL3 in pl-files
    if ( $Code =~ s{$GPLLongRegExp}{$AGPLLong}xms ) {
        print "NOTICE: _AGPL3LicenseCheck() replaced the license GPL2 with AGPL3 in pl-files\n";
        $Flag = 1;
    }

    # The following code replace the license GPL2 with AGPL3 in pm-files
    if ( $Code =~ s{$GPLShortRegExp}{$AGPLShort}xms ) {
        print "NOTICE: _AGPL3LicenseCheck() replaced the license GPL2 with AGPL3 in pm-files\n";
        $Flag = 1;
    }

    my $AGPLPerldoc      = _AGPLPerldoc();
    my $GPLPerldocRegExp = <<'    END_REGEXP';
        =head1 \s+ TERMS \s+ AND \s+ CONDITIONS \n
        \n
        This  \s+ software  \s+ is  \s+ part  \s+ of  \s+ the  \s+ OTRS  \s+ project  \s+ \(http:\/\/otrs\.org\/\)\. \n
        .+?
        did \s+ not \s+ receive \s+ this \s+ file, \s+ see \s+ http:\/\/www\.gnu\.org\/licenses\/gpl (?: -2\.0 |  ) \.txt\. \n
    END_REGEXP

    # The following code replace the license GPL2 with AGPL3 in perldoc content
    if ( $Code =~ s{$GPLPerldocRegExp}{$AGPLPerldoc}xms ) {
        print "NOTICE: _AGPL3LicenseCheck() replaced the license GPL2 with AGPL3 in perldoc content\n";
        $Flag = 1;
    }

    my $OldFSFAddress = '59 \s+ Temple \s+ Place, \s+ Suite \s+ 330, \s+ Boston, \s+ MA \s+ 02111-1307 \s+ USA';
    my $NewFSFAddress = '51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA';

    if ( $Code =~ s{$OldFSFAddress}{$NewFSFAddress}xms ) {
        print "NOTICE: _AGPL3LicenseCheck() updated the FSF Mailing Address\n";
        $Flag = 1;
    }

    # Links to AGPL should be within L<> (especially at the end of a sentence)
    # pod2html (resp. Pod::Html) would be "confused" otherwise
    $Code =~ s! ^ ([^\#] .+?) (http:// [^\s]+ agpl\.txt) ([^>])!$1L<$2>$3!xgms;

    # check if there other strange license content
    if ( $Code =~ m{(^ [^\n]* (?: \(GPL\) | /gpl ) [^\n]* $)}smx ) {
        die("WARNING: AGPL3LicenseCheck() - There is strange license wording! Line: $1");
    }

    print "NOTICE: _AGPL3LicenseCheck() ok\n";
    return $Code;
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
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

sub _AGPLPerldoc {
    return <<'END_AGPLPERLDOC';
=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.
END_AGPLPERLDOC

}

1;
