package Code::TidyAll::t::Plugin::SortLines;
{
  $Code::TidyAll::t::Plugin::SortLines::VERSION = '0.17';
}
use Test::Class::Most parent => 'Code::TidyAll::t::Plugin';

sub test_main : Tests {
    my $self = shift;

    $self->tidyall( source => "c\nb\na\n",   expect_tidy => "a\nb\nc\n" );
    $self->tidyall( source => "\n\na\n\n\n", expect_tidy => "a\n" );
}

1;
