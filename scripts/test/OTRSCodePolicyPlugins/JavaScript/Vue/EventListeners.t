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
        Name      => 'Event Listeners (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent', this.my_handler);
    }
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (multiple removes)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent', this.my_handler);
    }
    other_method() {
        this.$bus.$off('myEvent', this.my_handler);
    }
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (missing deregister)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent_withTypo', this.my_handler);
    }
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (anonymous function)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', (event) => { ... } ));
    }
    destroyed() {
        this.$bus.$off('myEvent', (event) => { ... } ));
    }
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (application event)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    vm.$bus.$on('myEvent', (event) => { ... } ));
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) document.addEventListener('keyup', this.onEscape);

// Stop listening on 'Esc' key presses.
if (this.isModal) document.removeEventListener('keyup', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, improper cleanup)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) document.addEventListener('keyup', this.onEscape);
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, local object)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) myNewNode.addEventListener('keyup', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, whitelisted event)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) window.addEventListener('beforeunload', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, mixed good and bad)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTRS::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) window.addEventListener('beforeunload', this.onEscape);
if (this.isModal) document.addEventListener('keyup', this.onEscape);
EOF
        Exception => 1,
    },

);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
