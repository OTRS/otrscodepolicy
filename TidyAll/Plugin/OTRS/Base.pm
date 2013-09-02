package TidyAll::Plugin::OTRS::Base;

use strict;
use warnings;

use Scalar::Util;

use base qw(Code::TidyAll::Plugin);

sub IsPluginDisabled {
    my ($Self, %Param) = @_;

    my $PluginPackage = Scalar::Util::blessed($Self);

    if (!defined $Param{Code} && !defined $Param{Filename}) {
        print STDERR "Need Code or Filename!\n";
        die;
    }

    my $Code = defined $Param{Code} ? $Param{Code} : $Self->_GetFileContents($Param{Filename});

    if ($Code =~ m{nofilter\([^()]*\Q$PluginPackage\E[^()]*\)}ismx) {
        return 1;
    }

    return;
}

sub IsFrameworkVersionLessThan {
    my ($Self, $FrameworkVersionMajor, $FrameworkVersionMinor) = @_;

    if ($Self->{tidyall}->{FrameworkVersionMajor}) {
        return 1 if $Self->{tidyall}->{FrameworkVersionMajor} < $FrameworkVersionMajor;
        return 0 if $Self->{tidyall}->{FrameworkVersionMajor} > $FrameworkVersionMajor;
        return 1 if $Self->{tidyall}->{FrameworkVersionMinor} < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;

}

sub _GetFileContents {
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
