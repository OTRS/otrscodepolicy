# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my $Helper     = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
my $Home       = $Kernel::OM->Get('Kernel::Config')->Get('Home');

my $RandomID = $Helper->GetRandomID();
my $SomeTest = <<"EOS";
use strict;
use warnings;
use vars (qw(\$Self));

\$Self->True(
    1,
    'Dummy test for UnitTestBlacklist plugin'
);
1;
EOS

my $SomeDirectory = "${Home}/scripts/test/SomeDirectory";
if ( !-d $SomeDirectory ) {
    mkdir $SomeDirectory;
}

my @TestFiles = (
    "SomeUnitTestBlacklist${RandomID}.t",
    "SomeDirectory/SomeUnitTestBlacklist${RandomID}.t",
    "OTRSCodePolicySomeUnitTestBlacklist${RandomID}.t",
    "SomeDirectory/OTRSCodePolicySomeUnitTestBlacklist${RandomID}.t",
);

for my $Item (@TestFiles) {

    my $Directory = '';
    my $TestFile  = $Item;
    if ( $TestFile =~ /SomeDirectory\/(.*)/ ) {
        $Directory = '/SomeDirectory';
        $TestFile  = "$1";
    }

    $TestFile = $MainObject->FileWrite(
        Directory => "${Home}/scripts/test${Directory}",
        Filename  => $TestFile,
        Content   => \$SomeTest,
    );

    $Self->True(
        $TestFile,
        'Created dummy test: ' . 'scripts/test' . $Directory . '/' . $TestFile
    );

}

my @Tests = (
    {
        Name      => 'There is overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<"EOF",
<Setting Name="UnitTest::Blacklist###100-OTRSCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">$TestFiles[0]</Item>
                <Item ValueType="String">$TestFiles[1]</Item>
            </Array>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
    {
        Name      => 'There is not overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<'EOF',
<Setting Name="UnitTest::Blacklist###100-OTRSCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">SomeUnitTestBlacklistNonExist.t</Item>
                <Item ValueType="String">SomeDirectory/SomeUnitTestBlacklistNonExist.t</Item>
            </Array>
        </Value>
    </Setting>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

for my $Item (@TestFiles) {

    my $Directory = '';
    my $TestFile  = $Item;
    if ( $TestFile =~ /SomeDirectory\/(.*)/ ) {
        $Directory = '/SomeDirectory';
        $TestFile  = "$1";
    }

    my $FileDeleted = $MainObject->FileDelete(
        Directory => "${Home}/scripts/test${Directory}",
        Filename  => "$TestFile",
    );
    $Self->True(
        $FileDeleted,
        'Deleted dummy test: scripts/test' . $Directory . '/' . $TestFile,
    );
}

my $Result = system("rm -rf $SomeDirectory");
$Self->False(
    $Result,
    "Deleted test directory: $SomeDirectory"
);

1;
