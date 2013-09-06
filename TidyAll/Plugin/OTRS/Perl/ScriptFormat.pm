# --
# TidyAll/Plugin/OTRS/Perl/ScriptFormat.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::ScriptFormat;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
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

1;
