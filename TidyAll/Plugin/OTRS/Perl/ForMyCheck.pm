package TidyAll::Plugin::OTRS::Perl::ForMyCheck;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    return if ($Self->IsFrameworkVersionLessThan(3, 3));


    my ($Counter, $ErrorMessage);

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ($Line =~ m{^ \s* for (each)? \s+ \$.+ \s+ \(  }xms) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ( $ErrorMessage ) {
        die __PACKAGE__ . "\n" . <<EOF;
Please use my to declare the key variable in
$ErrorMessage
EOF
    }
    return;
}

1;
