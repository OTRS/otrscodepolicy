# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::PO::HTMLTags;

#
# Filter forbidden HTML tags in Framework/Package translation files.
#

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

use Locale::PO ();

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $IsDocbookTranslation = $Filename =~ m{/doc-}smx;
    return if $IsDocbookTranslation;

    my @ForbiddenTags = (

        # Dangerous tags that could be used without attributes.
        qr(^<script)ixms,
        qr(^<style)ixms,
        qr(^<applet)ixms,
        qr(^<object)ixms,
        qr(^<svg)ixms,
        qr(^<embed)ixms,
        qr(^<meta)ixms,
        qr(^<img)ixms,
        qr(^<video)ixms,

        # Any HTML tag with additional attributes.
        qr(^<[^> ]+[ ]+[^>]+=)ixms,
    );

    my $Strings = Locale::PO->load_file_asarray($Filename);

    my $ErrorMessage;

    STRING:
    for my $String ( @{ $Strings // [] } ) {
        next STRING if $String->fuzzy();

        my $Source = $String->dequote( $String->msgid() ) // '';
        next STRING if !$Source;

        my $Translation = $String->dequote( $String->msgstr() ) // '';

        my @InvalidTags;

        for my $Part ( $Source, $Translation ) {
            my @Tags = $Part =~ m{<[^>]*>}smg;

            TAG:
            for my $Tag (@Tags) {
                for my $ForbiddenTag (@ForbiddenTags) {
                    push @InvalidTags, $Tag if $Tag =~ $ForbiddenTag;
                }
            }
        }

        next STRING if !@InvalidTags;

        $ErrorMessage .= "Invalid HTML tags found in line: " . $String->loaded_line_number() . "\n";
        $ErrorMessage .= "  Source: $Source\n";
        $ErrorMessage .= "  Translation: $Translation\n";
        $ErrorMessage .= "  Invalid tags: @InvalidTags";
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
