# --
# TidyAll/Plugin/OTRS/Common/RemoveCVSIDs.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Common::RemoveCVSIDs;
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use base qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    # remove $Id lines and the following separator line
    #
    # Perl files
    # $Id: Main.pm,v 1.69 2013-02-05 10:43:07 mg Exp $
    #
    # JavaScript files
    # // $Id: Core.Agent.Admin.DynamicField.js,v 1.11 2012-08-06 12:33:24 mg Exp $
    $Code =~ s{ ^ ( \# | // ) [ ] \$Id: [ ] .+? $ \n ( ^ ( \# | // ) [ ] -- $ \n )? }{}xmsg;

    # Postmaster-Test.box files
    # X-CVS: $Id: PostMaster-Test1.box,v 1.2 2007/04/12 23:55:55 martin Exp $
    $Code =~ s{ ^ X-CVS: [ ] \$Id: [ ] .+? $ \n }{}xmsg;

    # docbook and wsdl and other XML files
    # <!-- $Id: get-started.xml,v 1.1 2011-08-15 17:46:09 cr Exp $ -->
    $Code =~ s{ ^ <!-- [ ] \$Id: [ ] .+? $ \n }{}xmsg;

    # OTRS config files
    # <CVS>$Id: Framework.xml,v 1.519 2013-02-15 14:07:55 mg Exp $</CVS>
    $Code =~ s{ ^ \s* <CVS> \$Id: [ ] .+? $ \n }{}xmsg;

    # remove empty Ids
    # $Id:
    $Code =~ s{ ^ \# [ ] \$Id: $ \n }{}xmsg;

    ## remove $Date $ tag
    #$Code =~ s{ [ ]* \$Date: [^\$]+ \$ }{}xmsg;

    # Remove VERSION assignment from Code
    $Code =~ s{ ^\$VERSION [ ]* = [ ]* .*? \n}{}xmsg;

    # Remove VERSION from POD
    $Code =~ s{ ^=head1 [ ]* VERSION \n+ ^\$Revision: .*? \n+}{}xmsg;

    # delete the 'use vars qw($VERSION);' line
    $Code =~ s{ ( ^ $ \n )?  ^ use [ ] vars [ ] qw\(\$VERSION\); $ \n }{}ixms;

    # Remove @version tag from CSSDoc
    $Code =~ s{^ [ ]+ [*] [ ]+ [@]version [ ]+ \$Revision: .*? \n}{}xmsg;

    return $Code;
}

1;
