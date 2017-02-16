# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::OTRS::Perl::Pod::SpellCheck;
use strict;
use warnings;

# Implementation is based on https://metacpan.org/source/DROLSKY/Code-TidyAll-0.56/lib/Code/TidyAll/Plugin/PodSpell.pm

use Capture::Tiny qw();
use IPC::Run3;
use Pod::Spell;
use Text::ParseWords qw(shellwords);

use base 'TidyAll::Plugin::OTRS::Perl';

use Moo;

has 'ispell_argv' => (
    is      => 'ro',
    default => q{}
);
has 'ispell_cmd' => (
    is      => 'ro',
    default => 'ispell'
);
has 'suggest' => ( is => 'ro' );

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    # # TODO: MOVE TO SEPARATE Perl::CommentsSpellCheck plugin later
    # my $Code = $Self->_GetFileContents($File);
    #
    # my $Comments = $Self->StripPod( Code => $Code );
    # $Comments    =~ s{^ \# \s stripped \s POD}{}smxg;
    # $Comments    =~ s{^ \s* [^#\s] .*? $}{}smxg;  # Remove non-comment lines
    # $Comments    =~ s{\n\n+}{\n}smxg;             # Remove empty blocks
    # $Comments    =~ s{^ \s* [#] \s* }{}smxg;      # Remove comment signs

    my ( $PodText, $Error )
        = Capture::Tiny::capture( sub { Pod::Spell->new()->parse_from_file( $File->stringify() ) } );
    die $Error if $Error;

    #my $SpellCheckText = "$Comments\n$PodText";
    my $SpellCheckText = $PodText;

    my ($Output);
    my @CMD = ( $Self->ispell_cmd(), shellwords( $Self->ispell_argv() ), "-a" );
    eval { run3( \@CMD, \$SpellCheckText, \$Output, \$Error ) };

    if ($@) {
        $Error = $@;
        die "Error running '" . join( " ", @CMD ) . "': " . $Error;
    }

    my ( @Errors, %Seen );
    LINE:
    for my $Line ( split( "\n", $Output ) ) {
        if ( my ( $Original, $Remaining ) = ( $Line =~ /^[\&\?\#] (\S+)\s+(.*)/ ) ) {

            if ( $Original =~ m{^ _? [A-Z]+ [a-z0-9]+ [A-Za-z0-9]* }smx ) {
                next LINE;
            }

            if ( !$Seen{$Original}++ ) {
                my ($Suggestions) = ( $Remaining =~ /: (.*)/ );
                if ( $Suggestions && $Self->suggest() ) {
                    push( @Errors, sprintf( "%s (suggestions: %s)", $Original, $Suggestions ) );
                }
                else {
                    push( @Errors, $Original );
                }
            }
        }
    }
    die sprintf( "Pod contains unrecognized words:\n%s\n", join( "\n", sort @Errors ) ) if @Errors;
}

1;
