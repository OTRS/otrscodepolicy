# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::XML::Docbook::BinScripts;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin checks that bin scripts point to new paths.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my %AllowedFiles = (
        'otrs.CheckModules.pl'   => 1,
        'otrs.CheckSum.pl'       => 1,
        'otrs.CodePolicy.pl'     => 1,
        'otrs.Console.pl'        => 1,
        'otrs.Daemon.pl'         => 1,
        'otrs.SetPermissions.pl' => 1,
    );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ /bin\/(otrs\.\w+\.pl)/ismx ) {

            next LINE if $AllowedFiles{$1};

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't use old bin scrips in documentation.
$ErrorMessage
EOF
    }

    return;
}

1;
