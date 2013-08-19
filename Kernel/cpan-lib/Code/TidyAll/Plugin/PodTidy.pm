package Code::TidyAll::Plugin::PodTidy;
{
  $Code::TidyAll::Plugin::PodTidy::VERSION = '0.17';
}
use Capture::Tiny qw(capture_merged);
use Pod::Tidy;
use Moo;
extends 'Code::TidyAll::Plugin';

has 'columns' => ( is => 'ro' );

sub transform_file {
    my ( $self, $file ) = @_;

    my $output = capture_merged {
        Pod::Tidy::tidy_files(
            files    => [$file],
            inplace  => 1,
            nobackup => 1,
            verbose  => 1,
            ( $self->columns ? ( columns => $self->columns ) : () ),
        );
    };
    die $output if $output =~ /\S/ && $output !~ /does not contain Pod/;
}

1;

__END__

=pod

=head1 NAME

Code::TidyAll::Plugin::PodTidy - use podtidy with tidyall

=head1 VERSION

version 0.17

=head1 SYNOPSIS

   In configuration:

   [PodTidy]
   select = lib/**/*.{pm,pod}
   columns = 90

=head1 DESCRIPTION

Runs L<podtidy|podtidy>, which will tidy the POD in your Perl or POD-only file.

=head1 INSTALLATION

Install podtidy from CPAN.

    cpanm podtidy

=head1 CONFIGURATION

=over

=item columns

Number of columns per line

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
