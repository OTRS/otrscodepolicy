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
        Name      => 'Minimal valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en" Translatable="1">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing name.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing description.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing version.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing framework.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing vendor.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing URL.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing license.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Invalid content for PackageIsDownloadable flag.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>test</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTRSCodePolicy - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTRSCodePolicy - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'ITSMIncidentProblemManagement - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'ITSMIncidentProblemManagement - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'TimeAccounting - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'TimeAccounting - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'OTRSSTORM - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTRSSTORM - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Test123 - valid SOPM (no restricted package).',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTRS::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>Test123</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
