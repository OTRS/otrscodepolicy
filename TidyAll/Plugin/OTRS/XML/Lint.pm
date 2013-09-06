package TidyAll::Plugin::OTRS::XML::Lint;

use strict;
use warnings;


use Capture::Tiny qw(capture_merged);
use base qw(TidyAll::Plugin::OTRS::Base);

sub _build_cmd { 'xmllint' }

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $cmd = sprintf( "%s %s %s", $Self->cmd, $Self->argv, $Filename );
    my ($output, @result) = capture_merged { system($cmd) };
    if (@result && $result[0]) {
        die __PACKAGE__ . "\n$output\n" ; # non-zero exit code
    }
}

1;
