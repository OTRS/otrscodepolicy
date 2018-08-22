# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'PO::Lint, valid docbook',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::Lint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::Lint, valid docbook (ignored tag missing)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::Lint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <emphasis>this</emphasis> works"
msgstr "Ja das funktioniert"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::Lint, invalid docbook (invalid xml)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::Lint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert <extratag unclosed>"
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::Lint, invalid docbook (missing tags)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::Lint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "<placeholder type=\"screeninfo\" id=\"0\"/> <graphic srccredit=\"process-"
"management - screenshot\" scale='40' fileref=\"screenshots/pm-accordion-new-"
"transition.png\"></graphic>"
msgstr "Falsch übersetzt"
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
