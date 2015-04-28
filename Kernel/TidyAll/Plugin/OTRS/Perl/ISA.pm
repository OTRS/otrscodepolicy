# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ISA;
## nofilter(TidyAll::Plugin::OTRS::Perl::ISA)

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    # Don't allow push @ISA.
    if ( $Code =~ m{push\(?\s*\@ISA }xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Don't push to \@ISA, this can cause problems in persistent environments.
Use Main::RequireBaseClass() instead.
EOF
    }

    return;
}

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 3 );

    # remove useless use vars qw(@ISA); (where ISA is not used)
    if ( $Code !~ m{\@ISA.*\@ISA}smx ) {
        $Code =~ s{^use \s+ vars \s+ qw\(\@ISA\);\n+}{}smx;
    }

    return $Code;
}

1;
