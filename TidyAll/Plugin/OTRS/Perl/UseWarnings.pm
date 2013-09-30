# --
# TidyAll/Plugin/OTRS/Perl/UseWarnings.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::UseWarnings;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Perl);

# Perl::Critic will make sure that use strict is enabled.
# Now we check that use warnings is also.
sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    #return $Code if ($Self->IsFrameworkVersionLessThan(3, 3));

    # Check if use warnings is present, otherwise add it
    if ( $Code !~ m{^[ \t]*use\s+warnings;}mx ) {
        $Code =~ s{^[ \t]*use\s+strict;}{use strict;\nuse warnings;}mx;
    }

    return $Code;
}

1;
