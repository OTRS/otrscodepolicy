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
    'ConfigObject',
    'DBObject',
    'EncodeObject',
    'LogObject',
    'MainObject',
    'TimeObject',
);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

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

    # Real Get() calls.
    $Code =~ s{
        \$Kernel::OM->Get\( \s* ([^\$]$ValidListExpression) \s* \)
    }{
        push @UsedObjects, $Self->_CleanupObjectList($1);
    }esmxg;

    # For loops with Get().
    $Code =~ s{
        for \s+ (?: my \s+ \$[a-zA-z0-9_]+ \s+)? \(($ValidListExpression)\)\s*\{\n
            \s+ \$Self->\{\$.*?\} \s* (?://|\|\|)?= \s* \$Kernel::OM->Get\(\s*\$[a-zA-Z0-9_]+?\s*\); \s+
        \}
    }{
        push @UsedObjects, $Self->_CleanupObjectList($1);
    }esmxg;

    # ObjectHash() calls.
    $Code =~ s{
        \$Kernel::OM->ObjectHash\(
            \s+ Objects \s+ => \s+ \[
                \s* ($ValidListExpression)\s*
            \]
    }{
        push @UsedObjects, $Self->_CleanupObjectList($1);
    }esmxg;

    #
    # Now check the declared dependencies and compare.
    #
    my @DeclaredObjectDependencies = @DefaultObjectDependencies;
    $Code =~ s{
        ^our\s+\@ObjectDependencies\s+=\s+\(($ValidListExpression)\);
    }{
        @DeclaredObjectDependencies = $Self->_CleanupObjectList($1);
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

    if (@UndeclaredObjectDependencies) {
        my $ErrorMessage
            = "The following objects are used in the code, but not declared as dependencies: ";
        $ErrorMessage .= join( ', ', @UndeclaredObjectDependencies ) . ".\n";
        die __PACKAGE__ . "\n" . <<EOF;
$ErrorMessage
EOF
    }

    return;
}

# Small helper function to cleanup object lists in Perl code for OM.
sub _CleanupObjectList {
    my ( $Self, $Code ) = @_;

    my @Result;

    OBJECT:
    for my $Object ( split( m{\s+}, $Code ) ) {
        $Object =~ s/qw\(//;        # remove qw() marker start
        $Object =~ s/^[("']+//;     # remove leading quotes and parentheses
        $Object =~ s/[)"',]+$//;    # remove trailing comma, quotes and parentheses

        next OBJECT if !$Object;

        if ( $Object eq '@Kernel::System::ObjectManager::DefaultObjectDependencies' ) {
            push @Result, @DefaultObjectDependencies;
            next OBJECT;
        }

        push @Result, $Object;
    }

    return @Result;
}

1;
