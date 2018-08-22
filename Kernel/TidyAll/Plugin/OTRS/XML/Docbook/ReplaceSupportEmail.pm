# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::XML::Docbook::ReplaceSupportEmail;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

my $English1RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*        If \s+ you \s+ have \s+ questions \s+ regarding \s+ this \s+ package, \s+ please \s+ contact \s+ your \s+ support \s+ team
\s+        \(support\@otrs\.com\) \s+ for \s+ more \s+ information \. \n
\s*    <\/para> \n
END_REGEXP

my $English2RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*        If \s+ you \s+ have \s+ questions \s+ regarding \s+ this \s+ document \s+ or \s+ if \s+ you \s+ need \s+ further \s+ information, \s+ please \s+ log \s+ in \s+ to \s+ our \s+ customer \s+ portal \s+ at \s+ portal\.otrs\.com \s+ with \s+ your \s+ OTRS \s+ ID \s+ and \s+ create \s+ a \s+ ticket\.
\s+        You \s+ do \s+ not \s+ have \s+ an \s+ OTRS \s+ ID \s+ yet\? \s+ Register
\s*        <ulink \s+ url="https:\/\/portal\.otrs\.com\/otrs\/customer\.pl\#Signup">here \s+ for \s+ free<\/ulink>\.
\s*    <\/para> \n
END_REGEXP

my $German1RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*         Bei \s+ Fragen \s+ betreffend \s+ dieses \s+ Dokumentes, \s+ kontaktieren \s+ Sie \s+ Ihren \s+ Support \s+ \(support\@otrs\.com\) \s+ für \s+ weitere \s+ Informationen \. \n
\s*    <\/para> \n
END_REGEXP

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $EnglishReplacement = _EnglishReplacement();
    my $GermanReplacement  = _GermanReplacement();

    # replace support para
    $Code =~ s{$English1RegExp}{$EnglishReplacement}xms;
    $Code =~ s{$German1RegExp}{$GermanReplacement}xms;

    # Replace support para with the correct language
    if ( $Code =~ m{^ \s* <book \s+ lang='de'> }smx ) {
        $Code =~ s{$English2RegExp}{$GermanReplacement}xms;
    }

    return $Code;
}

sub _EnglishReplacement {
    return <<'END_REPLACEMENT';

    <para>
        If you have questions regarding this document or if you need further information, please log in to our customer portal at portal.otrs.com with your OTRS ID and create a ticket.
        You do not have an OTRS ID yet? Register
        <ulink url="https://portal.otrs.com/otrs/customer.pl#Signup">here for free</ulink>.
    </para>
END_REPLACEMENT
}

sub _GermanReplacement {
    return <<'END_REPLACEMENT';

    <para>
        Sollten Sie Fragen zu diesem Dokument haben oder weitere Informationen benötigen, loggen Sie sich bitte mit Ihrer OTRS-ID in unser Kundenportal unter portal.otrs.com ein und eröffnen Sie ein Ticket. Sie haben noch keine OTRS-ID? Registrieren Sie sich
        <ulink url="https://portal.otrs.com/otrs/customer.pl#Signup">hier kostenlos</ulink>.
    </para>
END_REPLACEMENT
}

1;
