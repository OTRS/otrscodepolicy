# --
# TidyAll/Plugin/OTRS/Perl/ScriptFormat.pm - code quality plugin
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ScriptFormat;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check for presence of shebang line
    if ( $Code !~ m{\A\#!/usr/bin/perl\s*(?:-w)?}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Need #!/usr/bin/perl at the start of script files.
EOF
    }
    return;
}

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 2 );

    # For framework 3.2 or later, rewrite /usr/bin/perl -w to
    # /usr/bin/perl
    # we use 'use warnings;' which works lexical and not global

    $Code =~ s{\A\#!/usr/bin/perl[ ]-w}{\#!/usr/bin/perl}xms;

    return $Code;
}

1;
