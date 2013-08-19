package Code::TidyAll::Test::Plugin::UpperText;
{
  $Code::TidyAll::Test::Plugin::UpperText::VERSION = '0.17';
}
use Moo;
extends 'Code::TidyAll::Plugin';

sub transform_source {
    my ( $self, $source ) = @_;
    if ( $source =~ /^[A-Z]*$/i ) {
        return uc($source);
    }
    else {
        die "non-alpha content found";
    }
}

1;
