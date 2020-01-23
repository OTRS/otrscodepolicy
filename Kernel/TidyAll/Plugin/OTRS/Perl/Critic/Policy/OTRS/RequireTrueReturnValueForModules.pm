# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::RequireTrueReturnValueForModules;

## no critic (Perl::Critic::Policy::OTRS::RequireCamelCase)

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{ :severities :classification :ppi };
use parent 'Perl::Critic::Policy';

use Readonly;

our $VERSION = '0.02';

Readonly::Scalar my $DESC => q{Modules and tests have to return a true value ("1;")};
Readonly::Scalar my $EXPL => q{Use "1;" as the last statement of the file};

sub supported_parameters { return; }
sub default_severity     { return $SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Document' }

# Only apply to Perl modules and test files, not to scripts.
sub prepare_to_scan_document {
    my ( $self, $document ) = @_;

    return $document->logical_filename() =~ m{ (\.pm|\.t) \z }xms;
}

sub violates {
    my ( $self, $elem ) = @_;

    my $last_statement = $elem->schild(-1);
    return if $last_statement && $last_statement eq '1;';

    return $self->violation( $DESC, $EXPL, $elem );
}

1;
