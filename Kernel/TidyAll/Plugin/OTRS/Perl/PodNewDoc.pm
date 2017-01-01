# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PodNewDoc;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my $ErrorMessage;

    # search for a new perldoc
    return 1 if $Code !~ m{=item \s new\(\) \n (.+?) =cut}xms;
    my $PodString = $1;

    # get all use calls
    my @Uses = $PodString =~ m{^ \s{4} use \s .+? ; \s* $}smxg;
    my %UseElement = map { $_ =~ m{^ \s{4} use \s (.+?) ; \s* $}smx; $1 => 1; } @Uses;

    # get all new calls
    my @News = $PodString =~ m{^ \s{4} (?:my|local) \s \$ .+? = [^\n]+? new \s* \( .*? $}smxg;
    my %NewElement = map { m{^ \s{4} (?:my|local) \s \$ .+? = \s ([^\n]+?) ->new\( .*? $}smx; $1 => 1; } @News;

    # compare use calls with new calls
    USE:
    for my $Use ( sort keys %UseElement ) {
        next USE if $NewElement{$Use};
        $ErrorMessage .= "You call a use for $Use, but there is no 'new' call.\n";
    }

    # compare new calls with use calls
    NEW:
    for my $New ( sort keys %NewElement ) {
        next NEW if $UseElement{$New};
        $ErrorMessage .= "You call a new for $New, but there is no 'use' call.\n";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
The perldoc for new() is inconsistent.
$ErrorMessage
EOF
    }

    return;
}

1;
