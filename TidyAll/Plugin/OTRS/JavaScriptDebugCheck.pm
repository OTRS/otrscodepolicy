package TidyAll::Plugin::OTRS::JavaScriptDebugCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::OTRS::PluginBase);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->is_disabled(Code => $Code);

    my $Error;
    my $Counter;

    for my $Line ( split(/\n/, $Code) ) {
        $Counter++;
        if ( $Line =~ m{ console\.log\( }xms ) {
            $Error .= "ERROR: JavaScriptDebugCheck() found a console.log() statement in line( $Counter ): $Line\n";
            $Error .= "This will break IE and Opera. Please remove it from your code.\n";
        }
    }
    die $Error if ($Error);
}

1;
