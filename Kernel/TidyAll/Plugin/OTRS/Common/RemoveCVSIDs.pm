# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Common::RemoveCVSIDs;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin removes old $Id:$ tags and similar tags that were automatically
inserted by CVS but are no longer supported by git, such as the $VERSION
variable assignment. Please verify if your code still runs after the removal.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Remove $Id lines
    #
    # Perl files
    # $Id: Main.pm,v 1.69 2013-02-05 10:43:07 mg Exp $
    #
    # JavaScript files
    # // $Id: Core.Agent.Admin.DynamicField.js,v 1.11 2012-08-06 12:33:24 mg Exp $
    $Code =~ s{ ^ (?: \# | \/\/ ) [ ] \$Id: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ ( (?: \# | \/\/ ) ) [ ] -- $ \n ^ (?: \# | \/\/ ) [ ] -- $ \n }{$1 --\n}xmsg;

    # Remove $OldId2, $OldId3 and $OldId4 lines
    #
    # Perl files
    # $OldId2: Main.pm,v 1.69 2013-02-05 10:43:07 mg Exp $
    #
    # JavaScript files
    # // $OldId2: Core.Agent.Admin.DynamicField.js,v 1.11 2012-08-06 12:33:24 mg Exp $
    $Code =~ s{ ^ (?: \# | \/\/ ) [ ] \$OldId2: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ (?: \# | \/\/ ) [ ] \$OldId3: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ (?: \# | \/\/ ) [ ] \$OldId4: [ ] .+? $ \n }{}xmsg;

    # Remove $Id from POD
    $Code =~ s{ ^ =head1 [ ]+ VERSION \n+ ^ \$Id: [ ]+ .+? \n+ }{}xmsg;

    # Postmaster-Test.box files
    # X-CVS: $Id: PostMaster-Test1.box,v 1.2 2007/04/12 23:55:55 martin Exp $
    $Code =~ s{ ^ X-CVS: [ ] \$Id: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ X-CVS: [ ] \$OldId: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ X-CVS: [ ] \$OldId2: [ ] .+? $ \n }{}xmsg;

    # docbook and wsdl and other XML files
    # <!-- $Id: get-started.xml,v 1.1 2011-08-15 17:46:09 cr Exp $ -->
    $Code =~ s{ ^ <!-- [ ] \$Id: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ <!-- [ ] \$OldId: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ <!-- [ ] \$OldId2: [ ] .+? $ \n }{}xmsg;

    # OTRS config files
    # <CVS>$Id: Framework.xml,v 1.519 2013-02-15 14:07:55 mg Exp $</CVS>
    $Code =~ s{ ^ \s* <CVS> \$Id: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ \s* <CVS> \$OldId: [ ] .+? $ \n }{}xmsg;
    $Code =~ s{ ^ \s* <CVS> \$OldId2: [ ] .+? $ \n }{}xmsg;

    # remove empty Ids
    # $Id:
    $Code =~ s{ ^ \# [ ] \$Id: $ \n }{}xmsg;
    $Code =~ s{ ^ \# [ ] \$OldId: $ \n }{}xmsg;
    $Code =~ s{ ^ \# [ ] \$OldId2: $ \n }{}xmsg;

    # Remove VERSION assignment from Code
    $Code =~ s{ ^\$VERSION [ ]* = [ ]* .*? \n}{}xmsg;

    # Remove VERSION from help of pl scripts
    $Code =~ s{ [ ]+ <Revision \s+ \$VERSION> [ ]+ }{ }xmsg;
    $Code =~ s{ <Revision \s+ \$VERSION> }{}xmsg;

    # Remove VERSION from POD
    $Code =~ s{ ^ =head1 [ ]+ VERSION \n+ ^ \$Revision: .*? \n+ }{}xmsg;

    # delete the 'use vars qw($VERSION);' line
    $Code =~ s{ ( ^ $ \n )? ^ use [ ] vars [ ] qw\(\$VERSION\); $ \n }{}ixms;

    # Remove @version tag from CSSDoc
    $Code =~ s{^ [ ]+ [*] [ ]+ [@]version [ ]+ \$Revision: .*? \n}{}xmsg;

    return $Code;
}

1;
