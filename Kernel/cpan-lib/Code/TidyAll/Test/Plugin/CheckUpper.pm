package Code::TidyAll::Test::Plugin::CheckUpper;
{
  $Code::TidyAll::Test::Plugin::CheckUpper::VERSION = '0.17';
}
use Moo;
extends 'Code::TidyAll::Plugin';

sub validate_source {
    my ( $self, $source ) = @_;
    die "lowercase found" if $source =~ /[a-z]/;
}

1;
