# --
# Copyright (C) 2001-2018 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::PO::Lint;

#
# Perform some quality checks on po files.
#

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

use Locale::PO  ();
use XML::Parser ();

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    my $IsDocbookTranslation = $Filename =~ m{/doc-}smx;

    my $Strings = Locale::PO->load_file_asarray($Filename);

    my $ErrorMessage;

    STRING:
    for my $String ( @{ $Strings // [] } ) {

        next STRING if $String->fuzzy();

        my $Source = $String->dequote( $String->msgid() );
        next STRING if !$Source;
        my $Translation = $String->dequote( $String->msgstr() );
        next STRING if !$Translation;

        if ($IsDocbookTranslation) {

            # # Don't validate contents of <screen> tags, they should have CDATA
            #next STRING if $String->automatic() && $String->automatic =~ m{<screen>$}smx;
            next STRING if $String->automatic() && $String->automatic() =~ m{CDATA$}smx;

            # Obsolete strings might loose CDATA comments
            next STRING if $String->obsolete();

            my $Parser = XML::Parser->new();
            if ( !eval { $Parser->parse("<book>$Translation</book>") } ) {
                $ErrorMessage .= "Invalid XML translation found in Line: "
                    . $String->loaded_line_number() . "\n";
                $ErrorMessage .= "  Source: $Source\n";
                $ErrorMessage .= "  Translation: $Translation\n";
                $ErrorMessage .= "  XML::Parser produced errors: $@\n";
                next STRING;
            }

            my $StrippedSource = $Source;
            $StrippedSource =~ s{<!--.*-->}{}smxg;

            my @SourceTags = $StrippedSource =~ m{<[^>]*>}smg;
            next STRING if !@SourceTags;
            my %SourceTagCount;
            @SourceTags = map { $_ =~ s{^<([/a-zA-Z_0-9]+).*}{$1}esmxg; $_ } @SourceTags;    ## no critic

            # Some tags which do not have to be validated as long as the xml structure is still valid.
            my %IgnoreTags = (
                'emphasis'   => 1,
                '/emphasis'  => 1,
                'citetitle'  => 1,
                '/citetitle' => 1,
                'ulink'      => 1,
                '/ulink'     => 1,
                'link'       => 1,
                '/link'      => 1,
                'filename'   => 1,
                '/filename'  => 1,
            );

            SOURCE_TAG:
            for my $SourceTag (@SourceTags) {
                next SOURCE_TAG if $IgnoreTags{$SourceTag};
                $SourceTagCount{$SourceTag}++;

            }

            for my $SourceTag ( sort keys %SourceTagCount ) {
                my @TranslatedTags     = $Translation =~ m{<$SourceTag[>| ]}smg;
                my $TranslatedTagCount = scalar @TranslatedTags;
                if ( $TranslatedTagCount != $SourceTagCount{$SourceTag} ) {
                    $ErrorMessage .= "Invalid XML translation found in Line: "
                        . $String->loaded_line_number() . "\n";
                    $ErrorMessage .= "  Source: $Source\n";
                    $ErrorMessage .= "  Translation: $Translation\n";
                    $ErrorMessage
                        .= "  Tag <$SourceTag> was expected $SourceTagCount{$SourceTag} but found $TranslatedTagCount times.\n";
                }
            }

            # Source and translation should have the same linkend definitions.
            my @SourceLinkEnds = $Source =~ m{<link[^>]+linkend=["']([^'"]+)['"]}smxg;
            my @TargetLinkEnds = $Translation =~ m{<link[^>]+linkend=["']([^'"]+)['"]}smxg;

            my $LinkEndsAreDifferent = $Self->_DataDiff(
                Data1 => [ sort { $a cmp $b } @SourceLinkEnds ],
                Data2 => [ sort { $a cmp $b } @TargetLinkEnds ],
            );

            if ($LinkEndsAreDifferent) {
                $ErrorMessage .= "Linkend definitions are different.\nSource:\n$Source\nTranslation:\n$Translation\n\n";
            }
        }
    }

    if ($ErrorMessage) {
        die __PACKAGE__ . "\n$ErrorMessage";
    }
}

1;
