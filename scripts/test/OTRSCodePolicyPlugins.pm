# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
package scripts::test::OTRSCodePolicyPlugins;    ## no critic

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';          # find TidyAll

use utf8;

use TidyAll::OTRS;

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );

    my $Home = $ConfigObject->Get('Home');

    # Suppress colored output to not clutter log files.
    local $ENV{OTRSCODEPOLICY_NOCOLOR} = 1;

    my $TidyAll = TidyAll::OTRS->new_from_conf_file(
        "$Home/Kernel/TidyAll/tidyallrc",
        no_cache   => 1,
        check_only => 1,
        mode       => 'tests',
        root_dir   => $Home,
        data_dir   => File::Spec->tmpdir(),

        #verbose    => 1,
    );

    TEST:
    for my $Test ( @{ $Param{Tests} } ) {

        # Set framework version in TidyAll so that plugins can use it.
        my ( $FrameworkVersionMajor, $FrameworkVersionMinor ) = $Test->{Framework} =~ m/(\d+)[.](\d+)/xms;
        $TidyAll::OTRS::FrameworkVersionMajor = $FrameworkVersionMajor;
        $TidyAll::OTRS::FrameworkVersionMinor = $FrameworkVersionMinor;

        # Set the list of files to the same one defined in the test case.
        @TidyAll::OTRS::FileList = @{ $Test->{FileList} // [] };

        my $Source = $Test->{Source};

        eval {
            for my $PluginModule ( @{ $Test->{Plugins} } ) {
                $MainObject->Require($PluginModule);
                my $Plugin = $PluginModule->new(
                    name    => $PluginModule,
                    tidyall => $TidyAll,
                );

                for my $Method (qw(preprocess_source process_source_or_file postprocess_source)) {
                    ($Source) = $Plugin->$Method( $Source, $Test->{Filename} );
                }
            }
        };

        my $Exception = $@;

        $Self->Is(
            $Exception ? 1 : 0,
            $Test->{Exception},
            "$Test->{Name} - " . ( $Exception ? "exception found:\n$Exception" : 'no exception' ),
        );

        next TEST if $Exception;

        $Self->Is(
            $Source,
            $Test->{Result} // $Test->{Source},
            "$Test->{Name} - result",
        );
    }

    return;
}

1;
