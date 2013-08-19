package Code::TidyAll::Plugin::CSSUnminifier;
{
  $Code::TidyAll::Plugin::CSSUnminifier::VERSION = '0.17';
}
use IPC::System::Simple qw(run);
use Moo;
extends 'Code::TidyAll::Plugin';

sub _build_cmd { 'cssunminifier' }

sub transform_file {
    my ( $self, $file ) = @_;

    run( $self->cmd, $self->argv, $file, $file );
}

1;

__END__

=pod

=head1 NAME

Code::TidyAll::Plugin::CSUnminifier - use cssunminifier with tidyall

=head1 VERSION

version 0.17

=head1 SYNOPSIS

   In configuration:

   [CSSUnminifier]
   select = static/**/*.css
   argv = -w=2

=head1 DESCRIPTION

Runs L<cssunminifier|https://npmjs.org/package/cssunminifier>, a simple CSS
tidier.

=head1 INSTALLATION

Install L<npm|https://npmjs.org/>, then run

    npm install cssunminifier -g

=head1 CONFIGURATION

=over

=item argv

Arguments to pass to C<cssunminifier>

=item cmd

Full path to C<cssunminifier>

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
