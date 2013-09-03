package TidyAll::Plugin::OTRS::Perl::SubDeclaration;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

=head1

This module checks for sub declarations with the brace in the following
line and corrects them.

    sub abc
    {
        ...
    }

will become:

    sub abc {
        ...
    }

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    #return $Code if ($Self->IsFrameworkVersionLessThan(3, 3));

    if ( $Code =~ m|^sub \s+ \w+ \s* \r?\n { |smx ) {
        $Code =~ s|^(sub \s+ \w+) \s* \r?\n { |$1 {|smxg;
    }

    return $Code;
}

1;
