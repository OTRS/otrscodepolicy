# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
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
        Name      => 'Minimal valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Simple PackageMerge',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0"></PackageMerge>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'PackageMerge without TargetVersion',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne"></PackageMerge>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'PackageMerge without Name',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge TargetVersion="2.0.0"></PackageMerge>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Simple PackageMerge',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <DatabaseUpgrade Type="post">
        <TableCreate Name="merge_package">
            <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
            <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
        </TableCreate>
    </DatabaseUpgrade>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseUpgrade Type="merge" IfPackage="OtherPackage" IfNotPackage="OtherPackage2">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseUpgrade>
    </PackageMerge>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'PackageMerge with invalid CodeInstall',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>http://otrs.org/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseInstall Type="merge">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseInstall>
    </PackageMerge>
</otrs_package>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
