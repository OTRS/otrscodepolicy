# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::OTRS::RequireTrueReturnValueForModules;

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.02';

my $Description = q{Modules and tests have to return a true value ("1;")};
my $Explanation = q{Use "1;" as the last statement of the file};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Document' }

# Only apply to Perl modules and test files, not to scripts.
sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    return $Document->logical_filename() =~ m{ (\.pm|\.t) \z }xms;
}

sub violates {
    my ( $Self, $Element ) = @_;

    my $LastStatement = $Element->schild(-1);
    return if $LastStatement && $LastStatement eq '1;';

    return $Self->violation( $Description, $Explanation, $Element );
}

1;
