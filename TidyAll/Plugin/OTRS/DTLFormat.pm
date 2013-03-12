package TidyAll::Plugin::OTRS::DTLFormat;

use strict;
use warnings;

BEGIN {
  $TidyAll::Plugin::OTRS::DTLFormat::VERSION = '0.1';
}
use Moo;
extends 'Code::TidyAll::Plugin';

sub transform_source {
    my ( $Self, $Code ) = @_;

    # get attributes
    my $Count = -1;
    my $Space = '    ';
    my $Content = '';
    my $Script = 0;
    my $TextArea = 0;
    my $Style = 0;
    my $Counter = 0;
    my $TextAreaFlag = 0;

    for my $Line ( split(/\n/, $Code) ) {
        $Counter++;
        $Line .= "\n";

        if ($Line =~ /^#/) {
            $Content .= $Line;
        }
        elsif ($Line =~ /<textarea/i && $Line !~ m|</textarea>|i) {
            $TextArea = 1;
            $Content .= $Line;
        }
        elsif ($TextArea) {
            $Content .= $Line;
            if ($Line =~ /<\/textarea/i) {
                $TextArea = 0;
            }
        }
        elsif ($Line =~ /<script/i) {
            $Script = 1;
            $Content .= $Line;
        }
        elsif ($Script) {
            $Content .= $Line;
            if ($Line =~ /<\/script/i) {
                $Script = 0;
            }
        }
        elsif ($Line =~ /<style/i) {
            $Style = 1;
            $Content .= $Line;
        }
        elsif ($Style) {
            $Content .= $Line;
            if ($Line =~ /<\/style/i) {
                $Style = 0;
            }
        }
        elsif ($Line =~ /^\s*$/ || $Line =~ /^\$/) {
            $Content .= $Line;
        }
        elsif ($Line =~ /^(\s+?|)(<\!--.*)$/) {
            $Content .= $2."\n";
        }
        else {
            my $NextCount = 0;
            my $ContentCount = 0;
            my $CloseCount = 0;
            my @IndentingElements = qw(
                body
                h1
                h2
                h3
                h4
                h5
                h6
                table
                thead
                tfoot
                tbody
                tr
                th
                td
                form
                fieldset
                head
                div
                span
                p
                a
                select
                button
                ul
                ol
                li
                colgroup
                label
                dl
                dt
                dd
            );
            my $IndentingElementString = join('|', @IndentingElements);
            if ($Line =~ /^(\s+?|)\<\/($IndentingElementString)(\s|>)/i) {
                $NextCount = 1;
            }
            elsif ($Line =~ /^(\s+?|)<($IndentingElementString)(\s|>)/i) {
                $Count ++;
                if ($Line =~ /<\/$2/) {
                    $CloseCount = 1;
                }
            }
            else {
                $ContentCount = 1;
            }
            $Line =~ s/^(\s*|\s|)(.*)$/$2/;
            my $LineNew = '';
            if ($Count+$ContentCount) {
                for (1..$Count+$ContentCount) {
                    $LineNew .= $Space;
                }
            }
            $Content .= $LineNew.$Line;
            if ($NextCount) {
                $Count--;
            }
            if ($CloseCount) {
                $Count--;
            }
        }

        if ($TextAreaFlag) {
            $TextAreaFlag = 0;
            if ($Line =~ /^ /) {
                print "WARNING: _DTLText() please check, please check the textarea-tag at Line $Counter, perhaps there are problems with the spaces.\n";
            }
        }
        if ($Line =~ /<textarea/i && $Line !~ /<\/textarea/i ) {
            $TextAreaFlag = 1;
        }

    }
    return $Content;
}

1;
