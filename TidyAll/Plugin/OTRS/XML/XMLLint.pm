use strict;
use warnings;

package TidyAll::Plugin::OTRS::XML::XMLLint;

use Capture::Tiny qw(capture_merged);
use base qw(TidyAll::Plugin::OTRS::Base);

sub _build_cmd { 'xmllint' }

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $cmd = sprintf( "%s %s %s", $Self->cmd, $Self->argv, $Filename );
    my ($output, @result) = capture_merged { system($cmd) };
    die "$output\n" if @result; # non-zero exit code
}

1;
