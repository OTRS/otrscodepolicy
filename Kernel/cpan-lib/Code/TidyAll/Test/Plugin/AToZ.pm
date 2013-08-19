package Code::TidyAll::Test::Plugin::AToZ;
{
  $Code::TidyAll::Test::Plugin::AToZ::VERSION = '0.17';
}
use Moo;
extends 'Code::TidyAll::Plugin';

sub preprocess_source {
    my ( $self, $source ) = @_;
    $source =~ tr/Aa/Zz/;
    return $source;
}

sub postprocess_source {
    my ( $self, $source ) = @_;
    $source =~ tr/Zz/Aa/;
    return $source;
}

1;
