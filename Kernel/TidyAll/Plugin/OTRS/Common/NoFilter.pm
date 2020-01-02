# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Common::NoFilter;
## nofilter(TidyAll::Plugin::OTRS::Perl::Pod::SpellCheck)

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Base);

=head1 SYNOPSIS

This plugin fixes nofilter lines.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace nofilter lines in pm like files.
    #
    # Original:
    #     # nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     # nofilter (TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     ## nofilter (TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     ## nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator);
    #     my $Dump = Data::Dumper::Dumper($HashRef);    #nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)
    #
    # Replacement:
    #     ## nofilter (TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    ## nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\#\n]* ) \#+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1## nofilter($2)\n}xmsg;

    # Replace nofilter lines in js like files.
    #
    # Original:
    #     // nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::OTRS::JavaScript::FileName)
    #     // nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)
    #
    # Replacement:
    #     // nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::OTRS::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\/\n]* ) \/+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1// nofilter($2)\n}xmsg;

    # Replace nofilter lines in css like files.
    #
    # Original:
    #     /* nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator) */
    #     /**  no filter (TidyAll::Plugin::OTRS::Legal::LicenseValidator) */
    #     /*  nofilter (TidyAll::Plugin::OTRS::Legal::LicenseValidator); */
    #
    # Replacement:
    #     /* nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator) */
    #
    $Code
        =~ s{ ^ ( \s* ) \\ \*+ [^\n]* no \s* filter \s* \( ( .+? ) \) .*? \*+ \\ [^\n]* \n }{$1/* nofilter($2) */\n}xmsg;

    # Replace nofilter lines in xml like files.
    #
    # Original:
    #     <!-- nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator) -->
    #     <!--  no filter (TidyAll::Plugin::OTRS::Legal::LicenseValidator) -->
    #     <!--  nofilter (TidyAll::Plugin::OTRS::Legal::LicenseValidator); -->
    #
    # Replacement:
    #     <!-- nofilter(TidyAll::Plugin::OTRS::Legal::LicenseValidator) -->
    #
    $Code
        =~ s{ ^ ( \s* ) <!-- [^\n]* no \s* filter \s* \( ( .+? ) \) .*? --> [^\n]* \n }{$1<!-- nofilter($2) -->\n}xmsg;

    return $Code;
}

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    return $Code if $Code !~ m{ nofilter \( .+? \) }xms;

    if ( $Code =~ m{ <!-- \s* nofilter \s* \( }xms ) {

        die __PACKAGE__ . "\nFound invalid nofilter() XML line!" if $Code !~ m{ <!-- \s nofilter \( .+? \) \s --> }xms;
    }
    else {

        die __PACKAGE__ . "\nFound invalid nofilter() line!"
            if $Code !~ m{ (?: \#\# | \/\/ | \/\* ) \s nofilter \( .+? \) }xms;
    }

    return $Code;
}

1;
