# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Tests::Roles;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 8, 0 );

    my %MatchRegexes = (
        ProvideTestPGPEnvironment   => qr{Kernel::Test::Role::Environment::ProvideTestPGPEnvironment}xms,
        ProvideTestSMIMEEnvironment => qr{Kernel::Test::Role::Environment::ProvideTestSMIMEEnvironment}xms,
        PGPInstantiation            => qr{->Get\('Kernel::System::Crypt::PGP'}xms,
        SMIMEInstantiation          => qr{->Get\('Kernel::System::Crypt::SMIME'}xms,
    );

    my %MatchPositions;

    for my $Key ( sort keys %MatchRegexes ) {
        if ( $Code =~ $MatchRegexes{$Key} ) {

            # Store the position of the first match.
            $MatchPositions{$Key} = $-[0];
        }
    }

    if ( $MatchPositions{PGPInstantiation} && !$MatchPositions{ProvideTestPGPEnvironment} ) {
        return $Self->DieWithError(<<"EOF");
PGP tests should always use the 'ProvideTestPGPEnvironment' role.
EOF
    }

    if ( $MatchPositions{SMIMEInstantiation} && !$MatchPositions{ProvideTestSMIMEEnvironment} ) {
        return $Self->DieWithError(<<"EOF");
SMIME tests should always use the 'ProvideTestSMIMEEnvironment' role.
EOF
    }

    return;
}

1;
