package TidyAll::Plugin::OTRS::Perl::ScriptFormat;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    # Check for presence of shebang line
    if ( $Code !~ m{\A\#!/usr/bin/perl\s*(?:-w)?}xms ) {
        die __PACKAGE__ . "\n" . <<EOF;
Need #!/usr/bin/perl at the start of script files.
EOF
    }
    return;
}

1;
