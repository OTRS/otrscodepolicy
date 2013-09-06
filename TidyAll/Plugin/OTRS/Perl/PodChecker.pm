# --
# TidyAll/Plugin/OTRS/Perl/PodChecker.pm - code quality plugin
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::PodChecker;

use Capture::Tiny qw(capture_merged);
use Pod::Checker;

use base 'Code::TidyAll::Plugin';
use base 'TidyAll::Plugin::OTRS::Base';

sub validate_file {
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if ( $Self->IsFrameworkVersionLessThan( 3, 2 ) );

    my $Checker = new Pod::Checker();
    my $Output = capture_merged { $Checker->parse_from_file( $File, \*STDERR ) };

    if ( $Checker->num_errors && $Output ) {
        die __PACKAGE__ . "\n$Output";
    }
}

1;
