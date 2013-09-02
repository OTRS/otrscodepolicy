package TidyAll::Plugin::OTRS::Perl::PodChecker;

use Capture::Tiny qw(capture_merged);
use Pod::Checker;

use Moo;
extends 'Code::TidyAll::Plugin';

extends 'TidyAll::Plugin::OTRS::Base';

has 'warnings' => ( is => 'ro' );

sub validate_file {
    my ( $self, $file ) = @_;

    return if $self->IsPluginDisabled( Filename => $file );
    return if ($self->IsFrameworkVersionLessThan(3, 2));

    my $result;
    my %options = ( defined( $self->warnings ) ? ( '-warnings' => $self->warnings ) : () );
    my $checker = new Pod::Checker(%options);
    my $output  = capture_merged { $checker->parse_from_file( $file, \*STDERR ) };
    die $output
      if $checker->num_errors
          or ( $self->warnings && $checker->num_warnings );
}

1;
