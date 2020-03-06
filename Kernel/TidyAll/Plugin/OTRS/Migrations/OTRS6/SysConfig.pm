# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::SysConfig;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 7, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        # Look for code that uses not not existing functions.
        if (
            $Line =~ m{
            ->(CreateConfig|ConfigItemUpdate|ConfigItemGet|ConfigItemReset
            |ConfigItemValidityUpdate|ConfigGroupList|ConfigSubGroupList
            |ConfigSubGroupConfigItemList|ConfigItemSearch|ConfigItemTranslatableStrings
            |ConfigItemValidate|ConfigItemCheckAll)\(}smx
            )
        {
            # Skip ITSM functions, which have same name.
            next LINE if $Line =~ m{ConfigItemObject};
            next LINE if $Line =~ m{ITSM};

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<EOF);
Use of unexisting methods in Kernel::System::SysConfig is not allowed (CreateConfig, ConfigItemUpdate,
ConfigItemGet, ConfigItemReset, ConfigItemValidityUpdate,ConfigGroupList, ConfigSubGroupList,
ConfigSubGroupConfigItemList, ConfigItemSearch, ConfigItemTranslatableStrings, ConfigItemValidate
and ConfigItemCheckAll).

    Please see http://doc.otrs.com/doc/manual/developer/6.0/en/html/package-porting.html#package-porting-5-to-6 for porting guidelines.
$ErrorMessage
EOF
    }

    return;
}

1;
