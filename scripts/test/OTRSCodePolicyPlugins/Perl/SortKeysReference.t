# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
## nofilter(TidyAll::Plugin::OTRS::Perl::SortKeys);

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'for Sort Keys Reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Keys Reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys $HashRef ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Sort Keys Hash as reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys \%Hash ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Keys Hash as reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys \%Hash ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Sort Keys unreferenced Hash, OK',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
        Exception => 0,
    },
    {
        Name      => 'for Keys unreferenced Hash, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys %{ $HashRef } ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
        Exception => 0,
    },
    {
        Name      => 'for Keys  Hash, OK',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTRS::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys %Hash ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys %Hash ) {
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
