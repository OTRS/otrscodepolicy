# --
# OTRSCodePolicyPlugins.pm - code policy self tests
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package scripts::test::OTRSCodePolicyPlugins;    ## no critic

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';          # find TidyAll

use utf8;

use TidyAll::OTRS;

sub Run {
    my ( $Self, %Param ) = @_;

    my $Home = $Self->{ConfigObject}->Get('Home');

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
        my ( $FrameworkVersionMajor, $FrameworkVersionMinor )
            = $Test->{Framework} =~ m/(\d+)[.](\d+)/xms;
        $TidyAll::OTRS::FrameworkVersionMajor = $FrameworkVersionMajor;
        $TidyAll::OTRS::FrameworkVersionMinor = $FrameworkVersionMinor;

        my $Source = $Test->{Source};

        eval {
            for my $PluginModule ( @{ $Test->{Plugins} } ) {
                $Self->{MainObject}->Require($PluginModule);
                my $Plugin = $PluginModule->new(
                    class   => $PluginModule,
                    name    => $PluginModule,
                    tidyall => $TidyAll,

                    #%$plugin_conf
                );

                for my $Method (qw(preprocess_source process_source_or_file postprocess_source)) {
                    $Source = $Plugin->$Method( $Source, $Test->{Filename} );
                }
            }
        };

        my $Exception = $@ ? 1 : 0;

        $Self->Is(
            $Exception,
            $Test->{Exception},
            "$Test->{Name} - exception found: $@",
        );

        next TEST if $Exception;

        $Self->Is(
            $Source,
            $Test->{Result} // $Test->{Source},
            "$Test->{Name} - result",
        );
    }
}

1;
