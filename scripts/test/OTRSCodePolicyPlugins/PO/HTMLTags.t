# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
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
        Name      => 'PO::HTMLTags, valid bold tag',
        Filename  => 'otrs.de.po',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "String with <b>tag</b>"
msgstr "Zeichenkette mit <b>Tag</b>"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::HTMLTags, forbidden script tag',
        Filename  => 'otrs.de.po',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "String with <sCrIpT>evil tag</script>"
msgstr "Zeichenkette mit <script>bösem Tag</script>"
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::HTMLTags, valid paragraph tag',
        Filename  => 'otrs.pot',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "<p>Paragraph string</p>"
msgstr ""
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::HTMLTags, forbidden meta tag',
        Filename  => 'otrs.pot',
        Plugins   => [qw(TidyAll::Plugin::OTRS::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "Redirecting now... <META http-equiv=\"refresh\" content=\"0; url=http://example.com/\">"
msgstr ""
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
