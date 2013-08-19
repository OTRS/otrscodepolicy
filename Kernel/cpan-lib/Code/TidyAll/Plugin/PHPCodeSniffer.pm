package Code::TidyAll::Plugin::PHPCodeSniffer;
{
  $Code::TidyAll::Plugin::PHPCodeSniffer::VERSION = '0.17';
}
use IPC::System::Simple qw(runx EXIT_ANY);
use Capture::Tiny qw(capture_merged);
use Moo;
extends 'Code::TidyAll::Plugin';

sub _build_cmd { 'phpcs' }

sub validate_file {
    my ( $self, $file ) = @_;

    my $exit;
    my @cmd = ( $self->cmd, $self->argv, $file );
    my $output = capture_merged { $exit = runx( EXIT_ANY, @cmd ) };
    if ( $exit > 0 ) {
        $output ||= "problem running " . $self->cmd;
        die "$output\n";
    }
}

1;

__END__

=pod

=head1 NAME

Code::TidyAll::Plugin::PHPCodeSniffer - use phpcs with tidyall

=head1 VERSION

version 0.17

=head1 SYNOPSIS

   In configuration:

   [PHPCodeSniffer]
   select = htdocs/**/*.{php,js,css}
   cmd = /usr/local/pear/bin/phpcs
   argv = --severity 4

=head1 DESCRIPTION

Runs L<phpcs|http://pear.php.net/package/PHP_CodeSniffer> which analyzes PHP,
JavaScript and CSS files and detects violations of a defined set of coding
standards.

=head1 VERSION

version 0.15

=head1 INSTALLATION

Install L<PEAR|http://pear.php.net/>, then install C<phpcs> from PEAR:

    pear install PHP_CodeSniffer

=head1 CONFIGURATION

=over

=item argv

Arguments to pass to C<phpcs>

=item cmd

Full path to C<phpcs>

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
