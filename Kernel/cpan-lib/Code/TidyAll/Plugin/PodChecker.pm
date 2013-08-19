package Code::TidyAll::Plugin::PodChecker;
{
  $Code::TidyAll::Plugin::PodChecker::VERSION = '0.17';
}
use Capture::Tiny qw(capture_merged);
use Pod::Checker;
use Moo;
extends 'Code::TidyAll::Plugin';

has 'warnings' => ( is => 'ro' );

sub validate_file {
    my ( $self, $file ) = @_;

    my $result;
    my %options = ( defined( $self->warnings ) ? ( '-warnings' => $self->warnings ) : () );
    my $checker = new Pod::Checker(%options);
    my $output  = capture_merged { $checker->parse_from_file( $file, \*STDERR ) };
    die $output
      if $checker->num_errors
      or ( $self->warnings && $checker->num_warnings );
}

1;

__END__

=pod

=head1 NAME

Code::TidyAll::Plugin::PodChecker - use podchecker with tidyall

=head1 VERSION

version 0.17

=head1 SYNOPSIS

   In configuration:

   ; Check for errors, but ignore warnings
   ;
   [PodChecker]
   select = lib/**/*.{pm,pod}

   ; Die on level 1 warnings (can also be set to 2)
   ;
   [PodChecker]
   select = lib/**/*.{pm,pod}
   warnings = 1

=head1 DESCRIPTION

Runs L<podchecker|podchecker>, a POD validator, and dies if any problems were
found.

=head1 INSTALLATION

Install podchecker from CPAN.

    cpanm podchecker

=head1 CONFIGURATION

=over

=item warnings

Level of warnings to consider as errors - 1 or 2. By default, warnings will be
ignored.

=back

=head1 SEE ALSO

L<Code::TidyAll|Code::TidyAll>

=head1 AUTHOR

Jonathan Swartz <swartz@pobox.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jonathan Swartz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
