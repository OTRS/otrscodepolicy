# --
# TidyAll/Plugin/OTRS/Perl/ObjectDependencies.pm - code quality plugin
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ObjectDependencies;

use strict;
use warnings;

#
# This plugin scans perl packages and compares the objects they request
#   from the ObjectManager with the dependencies they declare and complains
#   about any missing dependencies.
#

use base qw(TidyAll::Plugin::OTRS::Perl);

my @DefaultObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Time',
);

## nofilter(TidyAll::Plugin::OTRS::Perl::LayoutObject)
my %ObjectAliases = (
    'ACLDBACLObject' => 'Kernel::System::ACL::DB::ACL',
    'AuthObject' => 'Kernel::System::Auth',
    'AutoReponseObject' => 'Kernel::System::AutoResponse',
    'CacheObject' => 'Kernel::System::Cache',
    'CheckItemObject' => 'Kernel::System::CheckItem',
    'ConfigObject' => 'Kernel::Config',
    'CryptObject' => 'Kernel::System::Crypt',
    'CSVObject' => 'Kernel::System::CSV',
    'CustomerAuthObject' => 'Kernel::System::CustomerAuth',
    'CustomerCompanyObject' => 'Kernel::System::CustomerCompany',
    'CustomerGroupObject' => 'Kernel::System::CustomerGroup',
    'CustomerUserObject' => 'Kernel::System::CustomerUser',
    'DBObject' => 'Kernel::System::DB',
    'DebugLogObject' => 'Kernel::System::GenericInterface::DebugLog',
    'DynamicFieldBackendObject' => 'Kernel::System::DynamicField::Backend',
    'DynamicFieldObject' => 'Kernel::System::DynamicField',
    'EmailObject' => 'Kernel::System::Email',
    'EncodeObject' => 'Kernel::System::Encode',
    'EnvironmentObject' => 'Kernel::System::Environment',
    'FileTempObject' => 'Kernel::System::FileTemp',
    'GenericAgentObject' => 'Kernel::System::GenericAgent',
    'GroupObject' => 'Kernel::System::Group',
    'HTMLUtilsObject' => 'Kernel::System::HTMLUtils',
    'JSONObject' => 'Kernel::System::JSON',
    'LanguageObject' => 'Kernel::Language',
    'LayoutObject' => 'Kernel::Output::HTML::Layout',
    'LinkObject' => 'Kernel::System::LinkObject',
    'LoaderObject' => 'Kernel::System::Loader',
    'LockObject' => 'Kernel::System::Lock',
    'LogObject' => 'Kernel::System::Log',
    'MainObject' => 'Kernel::System::Main',
    'PackageObject' => 'Kernel::System::Package',
    'ParamObject' => 'Kernel::System::Web::Request',
    'PDFObject' => 'Kernel::System::PDF',
    'PIDObject' => 'Kernel::System::PID',
    'PostMasterObject' => 'Kernel::System::PostMaster',
    'PriorityObject' => 'Kernel::System::Priority',
    'QueueObject' => 'Kernel::System::Queue',
    'ServiceObject' => 'Kernel::System::Service',
    'SessionObject' => 'Kernel::System::AuthSession',
    'SLAObject' => 'Kernel::System::SLA',
    'StandardTemplateObject' => 'Kernel::System::StandardTemplate',
    'StateObject' => 'Kernel::System::State',
    'StatsObject' => 'Kernel::System::Stats',
    'SysConfigObject' => 'Kernel::System::SysConfig',
    'SystemAddressObject' => 'Kernel::System::SystemAddress',
    'TaskManagerObject' => 'Kernel::System::Scheduler::TaskManager',
    'TicketObject' => 'Kernel::System::Ticket',
    'TimeObject' => 'Kernel::System::Time',
    'TypeObject' => 'Kernel::System::Type',
    'UnitTestHelperObject' => 'Kernel::System::UnitTest::Helper',
    'UnitTestObject' => 'Kernel::System::UnitTest',
    'UserObject' => 'Kernel::System::User',
    'ValidObject' => 'Kernel::System::Valid',
    'WebserviceObject' => 'Kernel::System::GenericInterface::Webservice',
    'XMLObject' => 'Kernel::System::XML',
    'YAMLObject' => 'Kernel::System::YAML',
);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;
return 1;
    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 4 );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    # Skip if the code doesn't use the ObjectManager
    return if $Code !~ m{\$Kernel::OM};

    #
    # Ok, first check for the objects that are requested from OM.
    #
    my @UsedObjects;

    # Only math what is absolutely needed to avoid false positives.
    my $ValidListExpression = "[\@a-zA-Z0-9_[:space:]:'\",()]+?";

    my %ForbiddenObjectAliasUsage;

    # Real Get() calls.
    $Code =~ s{
        \$Kernel::OM->Get\( \s* ([^\$]$ValidListExpression) \s* \)
    }{
        my @Objects = $Self->_CleanupObjectList(
            Code => $1,
            ResolveObjectAlias => 0,
        );
        push @UsedObjects, @Objects;
        for my $Object (@Objects) {
            # Check if we have a full package name, otherwise complain
            if (index($Object, '::') < 0) {
                $ForbiddenObjectAliasUsage{$Object} = 1;
            }
        }
        '';
    }esmxg;

    # For loops with Get().
    $Code =~ s{
        for \s+ (?: my \s+ \$[a-zA-z0-9_]+ \s+)? \(($ValidListExpression)\)\s*\{\n
            \s+ \$Self->\{\$.*?\} \s* (?://|\|\|)?= \s* \$Kernel::OM->Get\(\s*\$[a-zA-Z0-9_]+?\s*\); \s+
        \}
    }{
        push @UsedObjects, $Self->_CleanupObjectList(
            Code => $1,
            ResolveObjectAlias => 1,
        );
        '';
    }esmxg;

    # ObjectHash() calls.
    $Code =~ s{
        \$Kernel::OM->ObjectHash\(
            \s+ Objects \s+ => \s+ \[
                \s* ($ValidListExpression)\s*
            \]
    }{
        push @UsedObjects, $Self->_CleanupObjectList(
            Code => $1,
            ResolveObjectAlias => 1,
        );
        '';
    }esmxg;

    #
    # Now check the declared dependencies and compare.
    #
    my @DeclaredObjectDependencies = @DefaultObjectDependencies;
    $Code =~ s{
        ^our\s+\@ObjectDependencies\s+=\s+\(($ValidListExpression)\);
    }{
        @DeclaredObjectDependencies = $Self->_CleanupObjectList(
            Code => $1,
            ResolveObjectAlias => 0,
        );
        '';
    }esmx;

    my %DeclaredObjectDependencyLookup;
    @DeclaredObjectDependencyLookup{@DeclaredObjectDependencies} = undef;

    my @UndeclaredObjectDependencies;
    my %Seen;
    USED_OBJECT:
    for my $UsedObject (@UsedObjects) {
        next USED_OBJECT if $Seen{$UsedObject}++;
        if ( !exists $DeclaredObjectDependencyLookup{$UsedObject} ) {
            push @UndeclaredObjectDependencies, $UsedObject;
        }
    }

    my $ErrorMessage;

    if (%ForbiddenObjectAliasUsage) {
        $ErrorMessage .= "Kernel::System::ObjectManager::Get() should only be used with the full package name, not the object alias.\n";
        $ErrorMessage .= "These aliases were found: " . join(', ', sort {$a cmp $b} keys %ForbiddenObjectAliasUsage) . ".\n";
    }

    if (@UndeclaredObjectDependencies) {
        $ErrorMessage .= "The following objects are used in the code, but not declared as dependencies: ";
        $ErrorMessage .= join( ', ', @UndeclaredObjectDependencies ) . ".\n";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
$ErrorMessage
EOF
    }

    return;
}

# Small helper function to cleanup object lists in Perl code for OM.
sub _CleanupObjectList {
    my ( $Self, %Param ) = @_;

    my @Result;

    OBJECT:
    for my $Object ( split( m{\s+}, $Param{Code} ) ) {
        $Object =~ s/qw\(//;        # remove qw() marker start
        $Object =~ s/^[("']+//;     # remove leading quotes and parentheses
        $Object =~ s/[)"',]+$//;    # remove trailing comma, quotes and parentheses
        next OBJECT if !$Object;
        if ($Param{ResolveObjectAlias}) {
            $Object = $ObjectAliases{$Object} // $Object;
        }
        push @Result, $Object;
    }

    return @Result;
}

1;
