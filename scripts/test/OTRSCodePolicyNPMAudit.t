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

use File::Basename;

my $BinDir = dirname($0);

my $ESLintDir = $BinDir . '/../Kernel/TidyAll/Plugin/OTRS/JavaScript/ESLint';
return 1 if !-d $ESLintDir;

my $NodeModulesDir = $ESLintDir . '/node_modules';
if ( !-d $NodeModulesDir ) {
    $Self->False(
        1,
        'Error: OTRSCodePolicy package not deployed correctly, node_modules folder missing!'
    );
    return 1;
}

# Performing NPM audit to make sure no new advisories are identified.
my $NPMAuditResultJSON = `cd $ESLintDir && npm audit --json`;

my $NPMAuditResult = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
    Data => $NPMAuditResultJSON,
);

my $VulnerabilityCount = 0;
my @Vulnerabilities;
for my $Severity (qw(low moderate high critical)) {
    $VulnerabilityCount += $NPMAuditResult->{metadata}->{vulnerabilities}->{$Severity};
    push @Vulnerabilities, "$NPMAuditResult->{metadata}->{vulnerabilities}->{$Severity} $Severity";
}

$Self->True(
    1,
    "Found ${\(join ', ', @Vulnerabilities)} vulnerabilities"
);

# Add muted advisory IDs to the list below.
my @MutedAdvisories    = qw();
my $MutedAdvisoryCount = scalar @MutedAdvisories;

my $AdvisoryCount = ( keys %{ $NPMAuditResult->{advisories} // {} } ) - $MutedAdvisoryCount;
$AdvisoryCount = 0 if $AdvisoryCount < 0;

$Self->True(
    1,
    "Found $AdvisoryCount security advisories ($MutedAdvisoryCount muted)"
);

ADVISORY_ID:
for my $AdvisoryID ( sort keys %{ $NPMAuditResult->{advisories} // {} } ) {
    next ADVISORY_ID if grep { $_ == $AdvisoryID } @MutedAdvisories;

    my $Advisory = $NPMAuditResult->{advisories}->{$AdvisoryID};

    $Self->False(
        1,
        "Security advisory for $Advisory->{module_name} module, severity $Advisory->{severity} (@{ $Advisory->{cves} // [] })"
    );
}

1;
