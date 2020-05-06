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
        Name      => 'Unique with name OTRS 8',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique without name OTRS 8',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique>
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index with name OTRS 8',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index Name="dynamic_field_object_name">
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index without name OTRS 8',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index>
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique with name OTRS 9',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique without name OTRS 9',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique>
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 1,
    },
    {
        Name      => 'Index with name OTRS 9',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index Name="dynamic_field_object_name">
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index without name OTRS 9',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index>
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
