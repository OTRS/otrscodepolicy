package TidyAll::Plugin::OTRS::Perl::SortKeys;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1

This module inserts a sort statements to lines like

    for my $Module (keys %Modules) ...

because the keys randomness can be a source of problems
that is hard to debug.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    return $Code if ($Self->IsFrameworkVersionLessThan(3, 2));

    $Code =~ s{ ^ (\s* for \s+ my \s+ \$ \w+ \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;
    $Code =~ s{ ^ (\s* for \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;

    return $Code;
}

1;
