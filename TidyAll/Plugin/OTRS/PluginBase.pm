package TidyAll::Plugin::OTRS::PluginBase;

use strict;
use warnings;

use Scalar::Util;

use base qw(Code::TidyAll::Plugin);

sub is_disabled {
    my ($Self, %Param) = @_;

    my $PluginPackage = Scalar::Util::reftype($Self);

    if (!$Param{Code} && !$Param{Filename}) {
        print STDERR "Need Code or Filename!\n";
        die;
    }

    my $Code = $Param{Code} || $Self->_get_file_contents($Param{Filename});

    if ($Code =~ m{nofilter\([^()]*\Q$PluginPackage\E[^()]*\)}ismx) {
        return 1;
    }

    return;
}

sub _get_file_contents {
    my ($Self, $Filename) = @_;

    my $FileHandle;
    if ( !open $FileHandle, '<', $Filename ) {
        print STDERR "Can't open $Filename\n";
        die;
    }

    my $Content = do { local $/; <$FileHandle> };
    close $FileHandle;

    return $Content;
}

1;
