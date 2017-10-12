# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTRSCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Bug#13199, dynamic_field_obj_id_name issue',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="dynamic_field_obj_id_name">
    <Column Name="object_id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Name="object_name" Required="true" Size="200" Type="VARCHAR"/>
    <Column Name="object_type" Required="true" Size="200" Type="VARCHAR"/>
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 1,
    },
    {
        Name      => 'Bug#13199, dynamic_field_obj_id_name fix',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="dynamic_field_obj_id_name">
    <Column Name="object_id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Name="object_name" Required="true" Size="200" Type="VARCHAR"/>
    <Column Name="object_type" Required="true" Size="100" Type="VARCHAR"/>
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Bug#13199, form_draft issue',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- form_draft -->
 <TableCreate Name="form_draft">
     <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER" />
     <Column Name="object_type" Required="true" Size="200" Type="VARCHAR" />
     <Column Name="object_id" Required="true" Type="INTEGER" />
     <Column Name="action" Required="true" Size="200" Type="VARCHAR" />
     <Column Name="title" Required="false" Size="255" Type="VARCHAR" />
     <Column Name="content" Required="true" Type="LONGBLOB" />
     <Column Name="create_time" Required="true" Type="DATE" />
     <Column Name="create_by" Required="true" Type="INTEGER" />
     <Column Name="change_time" Required="true" Type="DATE" />
     <Column Name="change_by" Required="true" Type="INTEGER" />
     <Index Name="form_draft_object_type_object_id_action">
         <IndexColumn Name="object_type" />
         <IndexColumn Name="object_id" />
         <IndexColumn Name="action" />
     </Index>
     <ForeignKey ForeignTable="users">
         <Reference Local="create_by" Foreign="id" />
         <Reference Local="change_by" Foreign="id" />
     </ForeignKey>
</TableCreate>
EOF
        Exception => 1,
    },
    {
        Name      => 'Bug#13199, form_draft fix',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- form_draft -->
 <TableCreate Name="form_draft">
     <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER" />
     <Column Name="object_type" Required="true" Size="100" Type="VARCHAR" />
     <Column Name="object_id" Required="true" Type="INTEGER" />
     <Column Name="action" Required="true" Size="200" Type="VARCHAR" />
     <Column Name="title" Required="false" Size="255" Type="VARCHAR" />
     <Column Name="content" Required="true" Type="LONGBLOB" />
     <Column Name="create_time" Required="true" Type="DATE" />
     <Column Name="create_by" Required="true" Type="INTEGER" />
     <Column Name="change_time" Required="true" Type="DATE" />
     <Column Name="change_by" Required="true" Type="INTEGER" />
     <Index Name="form_draft_object_type_object_id_action">
         <IndexColumn Name="object_type" />
         <IndexColumn Name="object_id" />
         <IndexColumn Name="action" />
     </Index>
     <ForeignKey ForeignTable="users">
         <Reference Local="create_by" Foreign="id" />
         <Reference Local="change_by" Foreign="id" />
     </ForeignKey>
</TableCreate>
EOF
        Exception => 0,
    },
    {
        Name      => 'Order of size tags, invalid',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="table_name">
    <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Name="column_one" Required="true" Type="VARCHAR" Size="100"/>
    <Column Name="column_two" Required="true" Size="200" Type="VARCHAR"/>
    <Column Name="column_three" Required="true" Type="VARCHAR" Size="100"/>
    <Unique Name="column_one_two_three">
        <UniqueColumn Name="column_one"/>
        <UniqueColumn Name="column_two"/>
        <UniqueColumn Name="column_three"/>
    </Unique>
</Table>
EOF
        Exception => 1,
    },
    {
        Name      => 'Size tags in keys, valid',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="table_name">
    <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Type="VARCHAR" Name="column_one" Required="true" Size="100"/>
    <Column Required="true" Size="200" Name="column_two" Type="VARCHAR"/>
    <Column Name="column_three" Type="VARCHAR" Required="true" Size="100"/>
    <Index Name="column_one_two_three">
        <IndexColumn Name="column_one"/>
        <IndexColumn Name="column_two" Size="100"/>
        <IndexColumn Name="column_three"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Integer column, valid',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="table_name">
    <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Type="VARCHAR" Name="column_one" Required="true" Size="330"/>
    <Column Required="true" Name="column_two" Type="BIGINT"/>
    <Index Name="column_one_two_three">
        <IndexColumn Name="column_one"/>
        <IndexColumn Name="column_two"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Integer column, invalid',
        Filename  => 'otrs-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTRS::XML::Database::KeyLength)],
        Framework => '6.0',
        Source    => <<"EOF",
<!-- object names for dynamic field values -->
<Table Name="table_name">
    <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Type="VARCHAR" Name="column_one" Required="true" Size="331"/>
    <Column Required="true" Name="column_two" Type="BIGINT"/>
    <Index Name="column_one_two_three">
        <IndexColumn Name="column_one"/>
        <IndexColumn Name="column_two"/>
    </Unique>
</Table>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTRSCodePolicyPlugins::Run( Tests => \@Tests );

1;
