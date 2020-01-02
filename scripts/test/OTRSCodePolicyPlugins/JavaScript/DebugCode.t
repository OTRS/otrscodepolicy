# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
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
        Name      => 'DebugCode - console logging (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::DebugCode)],
        Framework => '7.0',
        Source    => <<'EOF',
this.$log.debug('varName', varName);
EOF
        Exception => 0,
    },
    {
        Name      => 'DebugCode - console logging (invalid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
// TODO: Remove the code below.
this.$nextTick(() => {
    console.log('varName', varName);
});
EOF
        Exception => 1,
    },
    {
        Name      => 'DebugCode - skipped test (invalid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
    // TODO: Skip this test for now.
    xit('supports hiding of the description next to the label', () => {
        expect.assertions(2);

        wrapper.setProps({
            hideDescription: true,
        });

        wrapper.vm.$nextTick(() => {
            expect(wrapper.contains('label a.float-right i.CommonIcon__Bold--InformationCircle')).toBe(true);
            expect(wrapper.contains('small.sr-only')).toBe(true);
        });
    });
EOF
        Exception => 1,
    },
    {
        Name      => 'DebugCode - function similar in name to skipped test (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
function exit () {
    // Do something.
}
exit();
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
