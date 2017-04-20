# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ObjectNameSpace;

use strict;
use warnings;

#
# This plugin scans perl packages and compares the objects they request
#   from the ObjectManager with the dependencies they declare and complains
#   about any missing dependencies.
#

use parent qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    # Skip if the code doesn't use the ObjectManager
    return if $Code !~ m{\$Kernel::OM}smx;

    #
    # OK, first check for the objects that are requested from OM.
    #
    my @UsedObjects;

    # Only math what is absolutely needed to avoid false positives.
    my $ValidListExpression = "[\@a-zA-Z0-9_[:space:]:'\",()]+?";

    # Real Get() calls.
    $Code =~ s{
        \$Kernel::OM->Get\( \s* ([^\$]$ValidListExpression) \s* \)
    }{
        push @UsedObjects, $Self->_CleanupObjectList(
            Code => $1,
        );
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
        );
        '';
    }esmxg;

    my @WrongNameSpaces;
    my %Seen;
    USED_OBJECT:
    for my $UsedObject (@UsedObjects) {

        next USED_OBJECT if $Seen{$UsedObject};

        if ( $UsedObject !~ m{\A(?:[^:]+(::)*)+[^:]\z}msx ) {
            push @WrongNameSpaces, $UsedObject;
            $Seen{$UsedObject} = 1;
        }
    }

    my $ErrorMessage;
    if (@WrongNameSpaces) {
        $ErrorMessage
            .= "The name space for following objects is wrong:\n";
        $ErrorMessage
            .= join( ",\n", map {"    '$_'"} sort { $a cmp $b } @WrongNameSpaces )
            . ",\n";
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
        push @Result, $Object;
    }

    return @Result;
}

1;
